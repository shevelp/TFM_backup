'''
Generate an earth system model configuration from the given configuration file.

$Id$
'''

import os
import re
import StringIO
import time # for 'eval' context only

from itertools import dropwhile

import configobj
from configobj import InterpolationError

import feedback


class ConfigObj(configobj.ConfigObj):

    def __init__(self, *args, **kwargs):
        configobj.ConfigObj.__init__(self, *args, **kwargs)

    def merge(self, indict):

        def is_not_empty(arg):
            if arg is None:
                return None
            elif isinstance(arg, basestring):
                return arg.rstrip()
            else:
                return filter(None, map(lambda x: x.rstrip(), arg))

        def merge_comments(this, indict):
            '''Merge comments from indict into current configuration. 

            Requires indict to be merged before being called.
            '''
            if isinstance(indict, configobj.ConfigObj):
                if is_not_empty(indict.initial_comment):
                    this.initial_comment = indict.initial_comment
                if is_not_empty(indict.final_comment):
                    this.final_comment = indict.final_comment

            for key in indict.scalars:
                if is_not_empty(indict.comments[key]):
                    this.comments[key] = indict.comments[key]
                if is_not_empty(indict.inline_comments[key]):
                    this.inline_comments[key] = indict.inline_comments[key]
            
            for key in indict.sections:
                merge_comments(this[key], indict[key])

        configobj.ConfigObj.merge(self, indict)
        if isinstance(indict, configobj.Section):
            merge_comments(self, indict)


class ExpConfigError(InterpolationError):
    def __init__(self, message, key):
        message = message.rstrip('.!')
        InterpolationError.__init__(self, 
            "{0} while reading key '{1}'".format(message, key))

class ExpConfig(ConfigObj):
    '''Read and store configuration info from input and experiments' library

    Store environment as default for control settings, then add config from files
    '''
    
    #
    # Basic settings
    #

    exp_lib_dir = 'standard_experiments'
    env_lib_dir = 'standard_environments'
    opt_lib_dir = 'standard_options'
    default_name = 'DEFAULT'
    id_name = 'EXP_ID'
    setup_config_name = 'SETUP.config'

    # Class constructor

    def __init__(self, experiment_config_name,
                 extra_dict={}, config_roots=[''], getexp=False):
        '''Read experiment config to get basic settings
        
        TODO: probably nicer if default experiment is given as argument
        '''

        # State variables
        self.version_info_missing = False

        #
        # Helper functions
        #

        def split_jobs(config):
            '''Post-process job definition to allow for shared configs as [[job1, job2]]'''
            if 'jobs' in config:
                sep = re.compile(r'\s*,\s*')
                for subjobs, subconfig in config['jobs'].iteritems():
                    if re.search(sep, subjobs):
                        for subjob in re.split(sep, subjobs):
                            if subjob in config['jobs']:
                                config['jobs'][subjob].merge(subconfig.dict())
                            else:
                                config['jobs'][subjob] = subconfig.dict()
                        del config['jobs'][subjobs]

        def get_config_name(lib_name, base_name):
            '''Cycle through config path until a match is found.
               
               Return simple path otherwise'''
            config_name = os.path.join(lib_name, base_name)
            for config_root in config_roots:
                tentative_name = os.path.join(config_root, config_name)
                if os.path.exists(tentative_name):
                    config_name = tentative_name
                    break
            return config_name

        def read_value(value):
            if os.path.exists(value):
                stream = open(value)
                result = stream.read().strip()
                stream.close()
            else:
                result = ''
            return result

        def sec2time(seconds):
            '''Create time string (HH:MM:SS) from second of day'''
            seconds = int(seconds)
            if seconds >= 86400:
                raise ValueError("invalid second of day '{0}'".format(seconds))
            minutes, s = divmod(seconds, 60)
            h, m = divmod(minutes, 60)
            return "{0:02}:{1:02}:{2:02}".format(h, m, s)

        def split_date(value):
            '''Re-format datetime string to list for use in namelists'''
            match = re.match(r'^0*(\d+)-0*(\d+)-0*(\d+)'
                             r'([T ]0*(\d+)(:0*(\d+)(:0*(\d+))?)?)?$', value)
            if match:
                return [match.groups('0')[i] for i in [0,1,2,4,6,8]]

            match = re.match(r'^0*(\d+?)(\d{2})(\d{2})'
                             r'([T ]0*(\d+)(:0*(\d+)(:0*(\d+))?)?)?$', value)
            if match:
                return [match.groups('0')[i] for i in [0,1,2,4,6,8]]
                
            raise ValueError("invalid date/time '{0}'".format(value))

        def add_years(value, years):
            '''Add specified number of years (possible negative) to date'''
            years = int(years)
            dt = map(int, split_date(value))
            dt[0] += years
            return "{0:+05}-{1:02}-{2:02}".format(*dt).lstrip('+')

        def add_days(value, days):
            '''Add specified number of days (possible negative) to date'''
            def leap(year):
                return (not year % 4) and (not (not year % 100) or (not year % 400)) 
            def monlen(year, mon):
                monlens = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 0)
                return monlens[mon] + (mon == 2 and leap(year))
            def add_days_(year, mon, day, days):
                while True:
                    if mon == 0:
                        year -= 1
                        mon = 12
                        day = monlen(year, 12)
                        continue
                    if mon == 13:
                        year += 1
                        mon = 1
                        day = 1
                        continue
                    if day + days <= 0:
                        days += day
                        mon -= 1
                        day = monlen(year, mon)
                        continue
                    if day + days > monlen(year, mon):
                        days -= monlen(year, mon) - day + 1
                        mon += 1
                        day = 1
                        continue
                    day += days
                    break

                return (year, mon, day)

            days = int(days)
            dt = map(int, split_date(value))
            dt = add_days_(dt[0], dt[1], dt[2], days)
            return "{0:+05}-{1:02}-{2:02}".format(*dt).lstrip('+')

        def eval_value(value):
            '''
                Evaluate key as python expression,
                return as string or sequence of strings.
            '''
            result = eval(value)
            if isinstance(result, (list, tuple)):
                result = map(str, result)
            else:
                result = str(result)
            return result

        def eval_value_string(value):
            '''
                Evaluate key as python expression,
                return as string or sequence of strings.
            '''
            result = eval_value(value)
            if isinstance(result, (list, tuple)):
                result = ", ".join(result)
            return result

        def eval_expression(value):
            '''
                Check if value is a supported expression.
                If so, evaluate and return result, otherwise just pass through.
            '''
            match = re.match(r'^eval\((.*)\)$', value, re.S)
            if match:
                return eval_value(match.group(1))

            match = re.match(r'^evals\((.*)\)$', value, re.S)
            if match:
                return eval_value_string(match.group(1))

            match = re.match(r'^add_(years|days)\(\s*([-\d]+([T ][\d:]+)?)\s*,\s*([-+]?\d+)\s*\)$', value, re.S)
            if match:
                if match.group(1) == 'days':
                    return add_days(match.group(2), match.group(4))
                return add_years(match.group(2), match.group(4))

            match = re.match(r'^split_date\((.*)\)$', value, re.S)
            if match:
                return split_date(match.group(1))

            match = re.match(r'^sec2time\((.*)\)$', value, re.S)
            if match:
                return sec2time(match.group(1))

            match = re.match(r'^read\((.*)\)$', value, re.S)
            if match:
                return read_value(match.group(1))

            return value

        # Interpolate and evaluate keys if they are an expression
        def eval_key(section, key):
            try:
                value = section[key]
                if isinstance(value, (list, tuple)):
                    value = map(eval_expression, value)
                elif isinstance(value, basestring):
                    value = eval_expression(value)
                if isinstance(value, (list, tuple)):
                    value = [v.replace('$', '$$') for v in value]
                elif isinstance(value, basestring):
                    value = value.replace('$', '$$')
            except (InterpolationError, ValueError) as error:
                raise ExpConfigError(error.message, key)
            section[key] = value

        # Undo remaining changes from walk with eval_key
        def uneval_key(section, key):
            try:
                value = section[key]
                if isinstance(value, (list, tuple)):
                    value = [v.replace('$$', '$') for v in value]
                elif isinstance(value, basestring):
                    value = value.replace('$$', '$')
            except (InterpolationError, ValueError) as error:
                raise ExpConfigError(error.message, key)
            section[key] = value

        # Move version info from local config to global list
        def register_version(pre_config, config_versions):
            if 'VERSION_' in pre_config:
                config_versions.append(pre_config['VERSION_'])
                del pre_config['VERSION_']
            else:
                self.version_info_missing = True

        #
        # Method body
        #

        # Pre-read basic experiment settings

        pre_config = None
        setup_config_name = get_config_name('', ExpConfig.setup_config_name)
        if os.path.exists(setup_config_name):
            pre_config = ConfigObj(setup_config_name, interpolation=False)
        user_config = ConfigObj(experiment_config_name, interpolation=False)
        if pre_config:
            pre_config.merge(user_config)
        else:
            pre_config = user_config

        experiment_type = extra_dict.get('EXP_TYPE', pre_config['EXP_TYPE'])
        # Empty environment should load default
        environment = extra_dict.get('ENVIRONMENT', 
                      pre_config.get('ENVIRONMENT',
                      ExpConfig.default_name))
        # Options should always be treated as a list
        setup_options = extra_dict.get('SETUP_OPTIONS',
                        pre_config.get('SETUP_OPTIONS',
                        ''))
        if isinstance(setup_options, basestring):
            if setup_options:
                setup_options = [setup_options]
            else:
                setup_options = []
        exp_options = extra_dict.get('EXP_OPTIONS',
                      pre_config.get('EXP_OPTIONS',
                      ''))
        if isinstance(exp_options, basestring):
            if exp_options:
                exp_options = [exp_options]
            else:
                exp_options = []
        options = setup_options + exp_options
        # Backwards compatibility ENVIRONMENT -> QUEUE_TYPE
        if environment == ExpConfig.default_name and 'QUEUE_TYPE' in pre_config:
            feedback.warning("found obsolete keyword 'QUEUE_TYPE'; "
                             "should be replaced by 'ENVIRONMENT'")
            environment = pre_config['QUEUE_TYPE']
        # Load default if environment was deliberately set to empty
        if not environment:
            environment = ExpConfig.default_name

        pre_config = None
        user_config = None

        # Start from empty configuration

        pre_config = ConfigObj(interpolation=False)
        config_versions = []

        # Get default experiment id from file name
        pre_config[ExpConfig.id_name] = os.path.splitext(
            os.path.basename(experiment_config_name)
        )[0]

        # Read Environment

        env_dict = dict(os.environ)
        if not getexp:
            # Mask literal dollar characters
            for key, value in env_dict.iteritems():
                env_dict[key] = value.replace('$', '$$')
        pre_config.merge({'DEFAULT': {}})
        for key, value in sorted(env_dict.iteritems()):
            pre_config['DEFAULT'][key] = value

        # Read experiment settings from library (default and type specific)

        lib_config_name = get_config_name(ExpConfig.exp_lib_dir,
                                          ExpConfig.default_name+'.config')
        pre_config.merge(ConfigObj(lib_config_name, interpolation=False))
        split_jobs(pre_config)
        register_version(pre_config, config_versions)

        if os.path.exists(setup_config_name):
            pre_config.merge(ConfigObj(setup_config_name, interpolation=False))
            split_jobs(pre_config)
            register_version(pre_config, config_versions)

        lib_config_name = get_config_name(ExpConfig.exp_lib_dir, 
                                          experiment_type+'.config')
        if os.path.exists(lib_config_name):
            pre_config.merge(ConfigObj(lib_config_name, interpolation=False))
            split_jobs(pre_config)
            register_version(pre_config, config_versions)
        else:
            feedback.warning("cannot find experiment config for '%s', "+
                             "using default only", experiment_type)

        for option in options:
            lib_config_name = get_config_name(ExpConfig.opt_lib_dir, 
                                              option+'.config')
            if os.path.exists(lib_config_name):
                pre_config.merge(ConfigObj(lib_config_name, interpolation=False))
                split_jobs(pre_config)
                register_version(pre_config, config_versions)
            else:
                feedback.warning("cannot find config for option '%s', using "+
                                 "default/experiment type only", option)

        # Read host environment settings from library

        lib_config_name = get_config_name(ExpConfig.env_lib_dir,
                                          environment+'.config')

        if os.path.exists(lib_config_name):
            pre_config.merge(ConfigObj(lib_config_name, interpolation=False))
            register_version(pre_config, config_versions)

        # Warn user if at least one config had no version info
        if self.version_info_missing:
            feedback.info("version info for standard config is incomplete")

        # Re-read config to allow overriding default settings
        # TODO: probably nicer if default experiment is given as argument
        experiment_config = ConfigObj(experiment_config_name,
                                      interpolation=False)
        pre_config.merge(experiment_config)
        split_jobs(pre_config)

        # Add extra dictionary
        pre_config.merge(extra_dict)

        # Backwards compatibility ENVIRONMENT -> QUEUE_TYPE
        pre_config['ENVIRONMENT'] = environment

        # Add complete versioning info
        if not getexp:
            pre_config['VERSIONS_'] = config_versions

        # Re-read merged config with interpolation set.
        # This works around incomprehensible inheritance of interpolation with
        # merge. Make sure that all values are interpolated

        config_lines = StringIO.StringIO()

        pre_config.write(config_lines)
        pre_config = None

        config_lines.seek(0)
        pre_config = ConfigObj(config_lines,
                               interpolation=False if getexp else 'template')

        # Extract experiment description from initial comment
        # if not set explicitly
        if not pre_config.has_key('EXP_DESCRIPTION'):
            is_empty = lambda s: re.match(r'^[\s#]*$', s)
            rm_comment = lambda s: re.sub(r'^\s*# ?', '', s)       
            pre_config['EXP_DESCRIPTION'] = "\n".join(
                reversed(list(
                    dropwhile(is_empty,
                        reversed(list(
                            dropwhile(is_empty,
                                map(rm_comment,
                                    experiment_config.initial_comment)
                            )
                        )) 
                    )
                ))
            )

        pre_config.walk(eval_key)

        # Re-read final config without interpolation.
        # This allows copying data without evaluation of version keywords.

        config_lines.seek(0)
        config_lines.truncate()

        pre_config.write(config_lines)
        pre_config = None

        config_lines.seek(0)
        ConfigObj.__init__(self, config_lines, interpolation=False)
        self.walk(uneval_key)
        
        self.experiment_id = self[ExpConfig.id_name]
        self.experiment_kind = re.sub(r'-\w+$', '', experiment_type)

