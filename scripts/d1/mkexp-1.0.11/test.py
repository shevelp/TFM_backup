import os
import re
import sys
import unittest

from os.path import join



def align(string):
    return re.sub(r'\n\s*', '\n', string.lstrip())

def script(string):
    return align("""
        set -e
        unset CDPATH
        cd test
        PATH=..:$PATH
        MKEXP_PATH=
    """) + align(string)

def output(command):
    (ignore, stream) = os.popen4(command)
    return stream.read()

def readfile(filename):
    stream = open(filename)
    return stream.read()

def writefile(filename, string):
    stream = open(filename, 'w')
    stream.write(string)

def writeconfig(exp_id, string):
    writefile(join("test", exp_id+".config"), string)

def writetemplate(exp_id, job_id, string):
    writefile(join("test", exp_id+"."+job_id+".tmpl"), string)



class MkexpTestCase(unittest.TestCase):

    script_clean = script("""
        rm -rf experiments
        rm -f test_* SETUP.config
    """)

    script_run = script("""
        mkexp test0001.config
    """)

    def setUp(self):
        os.system(self.script_clean)

    @classmethod
    def tearDownClass(cls):
        os.system(cls.script_clean)

class MkexpSimpleTestCase(MkexpTestCase):

    def setUp(self):
        self.exp_id = self.id().split('.')[-1]
        self.job_id = 'job'
        MkexpTestCase.setUp(self)

    def run_test(self, template, expected, additional=''):
        writeconfig(self.exp_id, """
            EXP_TYPE =
            """+additional+"""
            [jobs]
              [["""+self.job_id+"""]]
        """)
        writetemplate(self.exp_id, self.job_id, template)
        expected = align(expected)
        ignore = output(script("mkexp "+self.exp_id+".config"))
        result = readfile(join("test", "experiments", self.exp_id,
                               self.exp_id+"."+self.job_id))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def run_no_template(self, result_path, expected, additional=''):
        writeconfig(self.exp_id, """
            EXP_TYPE =
            """+additional+"""
            [jobs]
              [["""+self.job_id+"""]]
        """)
        expected = align(expected)
        ignore = output(script("mkexp "+self.exp_id+".config"))
        result = readfile(join("test", "experiments", result_path))
        result = align(result)
        self.assertMultiLineEqual(expected, result)



class RunningTestCase(MkexpTestCase):

    def test_missing_config_file(self):
        result = output('./mkexp')
        self.assertIn('error: too few arguments', result)

    def test_clean_run(self):
        expected = align("""
            Script directory: 'experiments/test0001'
            Data directory: 'experiments/test0001'
        """)
        result = output(self.script_run)
        self.assertMultiLineEqual(expected, result)

    def test_backup_run(self):
        expected = "Hey: script directory already exists, "+\
                   "moving existing scripts to backup"
        ignore = output(self.script_run)
        result = output(self.script_run)
        self.assertIn(expected, result)

class CommandLineTestCase(MkexpTestCase):

    def test_pass_section_variables(self):
        script_section = script("""
            mkexp test0001.config \
                namelists.namelist..echam.runctl.dt_start=2345,01,23,12,34,56 \
                namelists.namelist..echam.runctl.some_file=abcdefgh.ijk
        """)
        expecteds = ["dt_start = 2345, 1, 23, 12, 34, 56",
                     "some_file = 'abcdefgh.ijk'"]
        ignore = output(script_section)
        result = readfile('test/experiments/test0001/test0001.run')
        for expected in expecteds:
            self.assertIn(expected, result)

    def test_pass_new_job(self):
        output(script("mkexp test0001.config jobs.dummy...extends=run"))
        readfile('test/experiments/test0001/test0001.dummy')
        # Should exist, otherwise exception is thrown

    def test_options(self):
        script_option = script("""
            mkexp test0001.config EXP_OPTIONS=option1
        """)
        expected = "default_output = .false."
        ignore = output(script_option)
        result = readfile('test/experiments/test0001/test0001.run')
        self.assertIn(expected, result)

    def test_getexp_vv(self):
        script_getexp = script("""
            mkexp test0001.config
            mv experiments/test0001 experiments/test0001.orig
            getexp -vv test0001.config MODEL_DIR=. > test_getexp.dump
            mkexp --getexp test_getexp.dump
        """)
        ignore = output(script_getexp)
        expected = readfile('test/experiments/test0001.orig/test0001.run')
        result = readfile('test/experiments/test0001/test0001.run')
        self.assertMultiLineEqual(expected, result)

    def test_getexp_k(self):
        result = output(script('getexp -k VAR1 test0001.config'))
        expected = align("""
            Note: data for experiment 'test0001' does not exist
            value1
        """)
        self.assertMultiLineEqual(expected, result)

    def test_getexp_k_k(self):
        result = output(script('getexp -k VAR1 -k VAR2 test0001.config'))
        expected = align("""
            Note: data for experiment 'test0001' does not exist
            value1
            value1
        """)
        self.assertMultiLineEqual(expected, result)

    def test_getexp_s(self):
        result = output(script('getexp -s -k VAR1 test0001.config'))
        expected = align("""
            Note: data for experiment 'test0001' does not exist
            VAR1='value1'
        """)
        self.assertMultiLineEqual(expected, result)

    def test_getconfig(self):
        ignore = output(script("""
            mkexp test0001.config VAR4=value4 jobs.run.time_limit=12:34:56
        """))
        result = output(script('getconfig experiments/test0001/update'))
        self.assertIn('VAR4 = value4', result)
        self.assertIn('time_limit = 12:34:56', result)

class ContentTestCase(MkexpSimpleTestCase):

    def test_job_override(self):
        exp_id = "test_job_override"
        writeconfig(exp_id, """
            EXP_TYPE =
            [jobs]
              key1 = global
              key2 = global
              [[job1]]
                key1 = local
        """)
        writetemplate(exp_id, "job1", """
            key1 = %{JOB.key1}
            key2 = %{JOB.key2}
        """)
        ignore = output(script("mkexp "+exp_id+".config"))
        result = readfile(join("test", "experiments", exp_id, exp_id+".job1"))
        self.assertIn("key1 = local", result)
        self.assertIn("key2 = global", result)

    def test_var_statement(self):
        exp_id = "test_var_statement"
        job_id = "job"
        writeconfig(exp_id, """
            EXP_TYPE = 
            GLOBAL1 = 123$${VAR1}456
            GLOBAL2 = $${VAR2}$${VAR3}
            GLOBAL3 = 1, $${VAR2}, 3
            GLOBAL${FOUR} = 4
            [namelists]
              [[namelist]]
                [[[group]]]
                  key = abc$${var}def
            [jobs]
              [["""+job_id+"""]]
                .var_format = <<<%s>>>
        """)
        writetemplate(exp_id, job_id, """
            GLOBAL1=%{GLOBAL1}
            GLOBAL2=%{GLOBAL2}
            GLOBAL3='%{GLOBAL3|join(" ")}'
            GLOBAL4=%{context("GLOBAL<<<FOUR>>>")}
            %{NAMELIST}
        """)
        expected = align("""
            GLOBAL1=123<<<VAR1>>>456
            GLOBAL2=<<<VAR2>>><<<VAR3>>>
            GLOBAL3='1 <<<VAR2>>> 3'
            GLOBAL4=4
            &group
                key = 'abc<<<var>>>def'
            /
        """)
        ignore = output(script("mkexp "+exp_id+".config"))
        result = readfile(join("test", "experiments", exp_id, exp_id+"."+job_id))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def test_var_list_in_context(self):
        exp_id = "test_var_list_in_context"
        job_id = "job"
        writeconfig(exp_id, """
            EXP_TYPE =
            VAR1 = value1
            GLOBAL1 = $${VAR1} # Initialized
            GLOBAL2 = $${VAR2} # Uninitialized
            GLOBAL3 = $${VAR1} # Used twice, may only be listed once
            GLOBAL${FOUR} = 4  # (Uninitialized) Variable in key
            [jobs]
              [["""+job_id+"""]]
        """)
        writetemplate(exp_id, job_id, """
            #% for var in VARIABLES_:
            %{var}=%{context(var)}
            #% endfor
        """)
        expected = align("""
            FOUR=
            VAR1=value1
            VAR2=
        """)
        ignore = output(script("mkexp "+exp_id+".config"))
        result = readfile(join("test", "experiments", exp_id, exp_id+"."+job_id))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def test_split_date(self):
        exp_id = 'test_split_date'
        job_id = 'job'
        writeconfig(exp_id, """
            EXP_TYPE =
            DATE_ISO = 1234-05-06
            DATE_RAW = 12340506
            DATE_LIST_ISO = split_date($DATE_ISO)
            DATE_LIST_RAW = split_date($DATE_RAW)
            [jobs]
              [["""+job_id+"""]]
        """)
        writetemplate(exp_id, job_id, """
            %{DATE_LIST_ISO|join(',')}
            %{DATE_LIST_RAW|join(',')}
        """)
        expected = align("""
            1234,5,6,0,0,0
            1234,05,06,0,0,0
        """)
        ignore = output(script("mkexp "+exp_id+".config"))
        result = readfile(join("test", "experiments", exp_id, exp_id+"."+job_id))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def test_add_years(self):
        exp_id = 'test_add_years'
        job_id = 'job'
        writeconfig(exp_id, """
            EXP_TYPE =
            DATE = 1234-05-06
            NEXT_DATE = 'add_years($DATE, 1)'
            PREVIOUS_DATE = 'add_years($DATE, -1)'
            NEGATIVE_DATE = 'add_years($DATE, -2000)'
            LONGYEAR_DATE = 'add_years($DATE, 10000)'
            [jobs]
              [["""+job_id+"""]]
        """)
        writetemplate(exp_id, job_id, """
            %{NEXT_DATE}
            %{PREVIOUS_DATE}
            %{NEGATIVE_DATE}
            %{LONGYEAR_DATE}
        """)
        expected = align("""
            1235-05-06
            1233-05-06
            -0766-05-06
            11234-05-06
        """)
        ignore = output(script("mkexp "+exp_id+".config"))
        result = readfile(join("test", "experiments", exp_id, exp_id+"."+job_id))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def test_add_days(self):
        exp_id = 'test_add_days'
        job_id = 'job'
        writeconfig(exp_id, """
            EXP_TYPE =
            DATE = 1234-05-06
            NEXT_DATE = 'add_days($DATE, 1)'
            PREVIOUS_DATE = 'add_days($DATE, -1)'
            NEGATIVE_DATE = 'add_days($DATE, -2000)'
            LONGYEAR_DATE = 'add_days($DATE, 10000)'
            LATE_DATE = 9999-12-31
            LATER_DATE = 'add_days($LATE_DATE, 1)'
            EARLY_DATE = 0000-01-01
            EARLIER_DATE = 'add_days($EARLY_DATE, -1)'
            [jobs]
              [["""+job_id+"""]]
        """)
        writetemplate(exp_id, job_id, """
            %{NEXT_DATE}
            %{PREVIOUS_DATE}
            %{NEGATIVE_DATE}
            %{LONGYEAR_DATE}
            %{LATER_DATE}
            %{EARLIER_DATE}
        """)
        expected = align("""
            1234-05-07
            1234-05-05
            1228-11-13
            1261-09-21
            10000-01-01
            -0001-12-31
        """)
        ignore = output(script("mkexp "+exp_id+".config"))
        result = readfile(join("test", "experiments", exp_id, exp_id+"."+job_id))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def test_eval(self):
        self.run_test("""
            %{VALUE}
        """, """
            42
        """, """
            VALUE = eval(5*8+2)
        """)

    def test_eval_time(self):
        self.run_test("""
            %{VALUE}
        """, """
            1970-01-01
        """, """
            VALUE = "eval(time.strftime('%Y-%m-%d', time.gmtime(0)))"
        """)

    def test_initial_comment_boilerplate(self):
        writeconfig(self.exp_id, """
            ######
            #    #
            # 42
            #    #
            ######
            EXP_TYPE =
            [jobs]
              [["""+self.job_id+"""]]
        """)
        writetemplate(self.exp_id, self.job_id, """
            %{EXP_DESCRIPTION}
        """)
        expected = align("""
            42
        """)
        ignore = output(script("mkexp "+self.exp_id+".config"))
        result = readfile(join("test", "experiments", self.exp_id,
                               self.exp_id+"."+self.job_id))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

class NamelistTestCase(MkexpSimpleTestCase):

    def test_namelist_comments(self):
        self.run_test("""
            %{NAMELIST}
        ""","""
            ! Comment group 1
            ! var_1c = 'test'
            &group_1
                ! Comment for var 1a
                var_1a = 42 ! Inline comment for var 1a
                ! var_1b = .true.
            /
            ! var_1d = 10.5
            &group_2
                ! Comment for var 2b
                var_2b = 21 ! Inline comment for var 2b
            /
        ""","""
            [namelists]
              [[namelist]]
                # Comment group 1
                # var_1c = test
                [[[group_1]]]
                  # Comment for var 1a
                  var_1a = 42 # Inline comment for var 1a
                  # var_1b = true
                  .end =
                  # var_1d = 10.5
                [[[group_2]]]
                  # Comment for var 2b
                  var_2b = 21 # Inline comment for var 2b
        """)

    def test_var_in_namelist(self):
        self.run_test("""
            %{NAMELIST}
        ""","""
            &group
                var_1 = $value_1
                var_2 = ${value_2}
                var_3 = 'a', $value_3, 'b'
                var_4 = 'a$value_4'
                var_5 = '${value_5}b'
            /
        ""","""
            [namelists]
              [[namelist]]
                [[[group]]]
                  var_1 = raw($$value_1)
                  var_2 = raw($${value_2})
                  var_3 = a, raw($$value_3), b
                  var_4 = a$$value_4
                  var_5 = $${value_5}b
        """)

    def test_namelist_multi_groups(self):
        self.run_test("""
            %{NAMELIST}
        """, """
            &group ! '1'
            /
            &group ! ' 1'
            /
            &group ! '2'
            /
            &group ! 'i i i'
            /
        """, """
            [namelists]
              [[namelist]]
                [[[group 1]]]
                [[[group  1]]]
                [[[group 2]]]
                [[[group i i i]]]
        """)

    def test_namelist_case_twist(self):
        self.run_test("""
            %{NAMELIST}
        """, """
            &group
                value = 41
                value = 42
            /
        """, """
            [namelists]
              [[namelist]]
                [[[group]]]
                   value = 41
                   VALUE = 42
        """)

    def test_namelist_format(self):
        self.run_test("""
            %{format_namelist(namelists.namelist)}
            %{format_namelist(namelists.namelist, 'group2')}
            %{format_namelist(namelists.namelist, 'no such group')}
        """, """
            &group1
                value = 41
            /
            &group2
                value = 42
            /
            &group2
                value = 42
            /
        """, """
            [namelists]
              [[namelist]]
                .remove = group3
                [[[group1]]]
                   value = 41
                [[[group2]]]
                   value = 42
                [[[group3]]]
                   value = 43
        """)

    def test_namelist_hide(self):
        self.run_test("""
            %{NAMELIST}
        """, """
            &group1
                value = 41
            /
            &group3
                value = 43
            /
        """, """
            [namelists]
              [[namelist]]
                [[[group1]]]
                   value = 41
                [[[group2]]]
                   .hide = true
                   value = 42
                [[[group3]]]
                   .hide = dont_care_if_we_dont_start_with_t
                   value = 43
        """)

class JinjaTemplateTestCase(MkexpSimpleTestCase):

    def test_ignore_blocks(self):
        self.run_test("""
            {% set answer = 42 %}
        """, """
            {% set answer = 42 %}
        """)

    def test_ignore_comments(self):
        self.run_test("""
            {# no comment #}
            ${#ARRAY}
        """, """
            {# no comment #}
            ${#ARRAY}
        """)

class DefaultEnvironmentTestCase(MkexpSimpleTestCase):

    def test_basic(self):
       self.run_test("""
           %{ENVIRONMENT}
       """, """
           DEFAULT
       """)

    def test_explicit(self):
       self.run_test("""
           %{ENVIRONMENT}
       """, """
           green
       """, """
           ENVIRONMENT = green
       """)

    def test_setup(self):
       writeconfig('SETUP', """
           ENVIRONMENT = 
       """)
       self.run_test("""
           %{ENVIRONMENT}
       """, """
           DEFAULT
       """)

class SetupConfigTestCase(MkexpSimpleTestCase):

    def test_system_options(self):
       writeconfig('SETUP', """
           SETUP_OPTIONS = option1
       """)
       self.run_test("""
           %{NAMELIST_ECHAM}
       """, """
           &runctl
             default_output = .false.
           /
       """, """
           EXP_OPTIONS =
       """)
           
class MatchTestCase(MkexpSimpleTestCase):

    def test_basic(self):
       self.run_test("""
           %{'Douglas Adams'|match('Adam')}
       """, """
           Douglas Adams
       """)

    def test_no_match(self):
       self.run_test("""
           %{'Douglas Adams'|match('Eva')}
       """, """
           
       """)

    def test_with_default(self):
       self.run_test("""
           %{'Douglas Adams'|match('Abel', 'Kain')}
       """, """
           Kain
       """)

    def test_with_group(self):
       self.run_test("""
           %{'Douglas Adams'|match('l(.*)m')}
       """, """
           as Ada
       """)

class WordwrapTestCase(MkexpSimpleTestCase):

    def test_basic(self):
        self.run_test("""
            %{'long-arbitrarilyhyphenated textlike-message'|wordwrap(15)}
        """, """
            long-arbitraril
            yhyphenated
            textlike-
            message
        """)

    def test_keep_long(self):
        self.run_test("""
            %{'long-arbitrarilyhyphenated textlike-message'|wordwrap(15,false)}
        """, """
            long-
            arbitrarilyhyphenated
            textlike-
            message
        """)

    def test_keep_long_hyphens(self):
        self.run_test("""
            %{'long-arbitrarilyhyphenated textlike-message'|wordwrap(15,false,false)}
        """, """
            long-arbitrarilyhyphenated
            textlike-message
        """)

    def test_keep_hyphens(self):
        self.run_test("""
            %{'long-arbitrarilyhyphenated textlike-message'|wordwrap(15,true,false)}
        """, """
            long-arbitraril
            yhyphenated tex
            tlike-message
        """)

class ListTestCase(MkexpSimpleTestCase):

    def test_list_on_string(self):
        self.run_test("""
            %{'first'|list}
        """, """
            ['first']
        """)

    def test_list_on_empty_string(self):
        self.run_test("""
            %{''|list}
        """, """
            []
        """)

    def test_list_keep_empty_string(self):
        self.run_test("""
            %{''|list(true)}
        """, """
            ['']
        """)

    def test_list_on_list(self):
        self.run_test("""
            %{['first', 'second', 'third']|list}
        """, """
            ['first', 'second', 'third']
        """)

    def test_list_on_int(self):
        self.run_test("""
            %{42|list}
        """, """
            [42]
        """)

    def test_list_on_tuple(self):
        self.run_test("""
            %{('first', 'second', 'third')|list}
        """, """
             ['first', 'second', 'third']
        """)

class JoinTestCase(MkexpSimpleTestCase):

    def test_join_on_string(self):
        self.run_test("""
            %{'first'|join(', ')}
        """, """
            first
        """)

    def test_join_on_empty_string(self):
        self.run_test("""
            %{''|join}
        """, """
        """)

    def test_join_on_list(self):
        self.run_test("""
            %{['first', 'second', 'third']|join(', ')}
        """, """
            first, second, third
        """)

    def test_join_on_int(self):
        self.run_test("""
            %{42|join(', ')}
        """, """
            42
        """)

    def test_join_on_tuple(self):
        self.run_test("""
            %{('first', 'second', 'third')|join(', ')}
        """, """
             first, second, third
        """)

class IsSetTestCase(MkexpSimpleTestCase):

    def test_empty_string(self):
        self.run_test("""
            %{'' is set}
        """, """
            False
        """)

    def test_true(self):
        self.run_test("""
            %{'true' is set}
        """, """
            True
        """)

    def test_namelist_true(self):
        self.run_test("""
            %{'.true.' is set}
        """, """
            True
        """)

    def test_false(self):
        self.run_test("""
            %{'false' is set}
        """, """
            False
        """)

    def test_test(self):
        self.run_test("""
            %{'.test.' is set}
        """, """
            True
        """)

    def test_undefined(self):
        self.run_test("""
            %{undefined_variable_name is set}
        """, """
            False
        """)

    def test_undefined_with_true_default(self):
        self.run_test("""
            %{undefined_variable_name|d('t') is set}
        """, """
            True
        """)

class FilesTestCase(MkexpSimpleTestCase):

    def test_get_file_simple(self):
        self.run_test("""
            %{get_file(files, 'target.txt')}
            %{get_file(files, 'broken.txt')}
        """, """
            source.txt
            .
        """, """
            [files]
                target.txt = source.txt
                broken.txt = .
        """)

    def test_get_file_path(self):
        self.run_test("""
            %{get_file(files, 'target.txt')}
            %{get_file(files, 'path.txt')}
            %{get_file(files.subdir, 'target.txt')}
        """, """
            /path/to/source/source.txt
            /just/this/one/source.txt
            /path/to/source/subdir/source.txt
        """, """
            [files]
                .base_dir = /path/to/source
                target.txt = source.txt
                path.txt = /just/this/one/source.txt
                [[subdir]]
                    .sub_dir = subdir
                    target.txt = source.txt
        """)

    def test_get_file_variable(self):
        self.run_test("""
            %{get_file(files, 'target.txt')}
            %{get_file(files, 'broken.txt')}
            %{get_file(files, 'incomplete.txt')}
        """, """
            source.txt
            $BASENAME.txt
            ${DOES_NOT_EXIST}.txt
        """, """
            BASENAME = source
            [files]
                target.txt = $${BASENAME}.txt
                broken.txt = $$BASENAME.txt
                incomplete.txt = $${DOES_NOT_EXIST}.txt
        """)

    def test_get_dir(self):
        self.run_test("""
            %{get_dir(files)}
            %{get_dir(files.subdir)}
        """, """
            /path/to/source
            /path/to/source/subdir
        """, """
            [files]
                .base_dir = /path/to/source
                [[subdir]]
                    .sub_dir = subdir
        """)

class GetTemplatesTestCase(MkexpSimpleTestCase):

    def test_by_config_file_name(self):
        other_exp_id = 'test_something_completely_different'
        writetemplate(self.exp_id, self.job_id, """
            selected by config file name
        """)
        self.run_no_template(join(other_exp_id, other_exp_id+'.'+self.job_id),
        """
            selected by config file name
        """, """
            EXP_ID = """+other_exp_id+"""
        """)

    def test_by_exp_id(self):
        other_exp_id = 'test_something_completely_different'
        writetemplate(other_exp_id, self.job_id, """
            selected by EXP_ID
        """)
        self.run_no_template(join(other_exp_id, other_exp_id+'.'+self.job_id),
        """
            selected by EXP_ID
        """, """
            EXP_ID = """+other_exp_id+"""
        """)

class DelimiterTestCase(MkexpSimpleTestCase):

    def test_statement(self):
        self.run_test("""
            {%__mkexp__
                set x = 'Hello, world!'
            %}
            %{x}
        """, """
            Hello, world!
        """)

    def test_comment(self):
        self.run_test("""
            {#__mkexp__
                Now you see me - now you don't
            #}
        """, """
        """)

class InheritanceTestCase(MkexpSimpleTestCase):

    def test_child_template(self):
        writeconfig(self.exp_id, """
            EXP_TYPE =
            [jobs]
              [[job1]]
              [[job2]]
                .extends = job1
        """)
        writetemplate(self.exp_id, 'job1', """
            %{JOB.id} as in job1
        """)
        writetemplate(self.exp_id, 'job2', """
            %{JOB.id} as in job2
        """)
        expected = align("""
            job2 as in job2
        """)
        ignore = output(script("mkexp "+self.exp_id+".config"))
        result = readfile(join("test", "experiments", self.exp_id,
                               self.exp_id+".job2"))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def test_parent_template(self):
        writeconfig(self.exp_id, """
            EXP_TYPE =
            [jobs]
              [[job1]]
              [[job2]]
                .extends = job1
        """)
        writetemplate(self.exp_id, 'job1', """
            %{JOB.id} as in job1
        """)
        expected = align("""
            job2 as in job1
        """)
        ignore = output(script("mkexp "+self.exp_id+".config"))
        result = readfile(join("test", "experiments", self.exp_id,
                               self.exp_id+".job2"))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def test_grandparent_template(self):
        writeconfig(self.exp_id, """
            EXP_TYPE =
            [jobs]
              [[job1]]
              [[job2]]
                .extends = job1
              [[job3]]
                .extends = job2
        """)
        writetemplate(self.exp_id, 'job1', """
            %{JOB.id} as in job1
        """)
        expected = align("""
            job3 as in job1
        """)
        ignore = output(script("mkexp "+self.exp_id+".config"))
        result = readfile(join("test", "experiments", self.exp_id,
                               self.exp_id+".job3"))
        result = align(result)
        self.assertMultiLineEqual(expected, result)

    def test_variable_ancestry(self):
        writeconfig(self.exp_id, """
            EXP_TYPE =
            [jobs]
              var_0 = from jobs
              [[job1]]
                var_1 = from job1
                var_2 = from job1
                var_3 = from job1
              [[job2]]
                .extends = job1
                var_2 = from job2
                var_3 = from job2
              [[job3]]
                .extends = job2
                var_0 = not needed
                var_3 = from job3
        """)
        writetemplate(self.exp_id, 'job1', """
            %{JOB.id}
            %{JOB.var_0}
            %{JOB.var_1}
            %{JOB.var_2}
            %{JOB.var_3}
        """)
        expecteds = map(align, (
            """
                job1
                from jobs
                from job1
                from job1
                from job1
            """,
            """
                job2
                from jobs
                from job1
                from job2
                from job2
            """,
            """
                job3
                not needed
                from job1
                from job2
                from job3
            """))
        ignore = output(script("mkexp "+self.exp_id+".config"))
        for i in (1, 2, 3):
            result = readfile(join("test", "experiments", self.exp_id,
                                   self.exp_id+".job%d"%i))
            result = align(result)
            self.assertMultiLineEqual(expecteds[i-1], result)

class JobSiblingsTestCase(MkexpSimpleTestCase):

    def test_sibling_lookup(self):
        writeconfig(self.exp_id, """
            EXP_TYPE =
            [jobs]
              [[job1]]
                seniority = elder
              [[job2]]
                seniority = younger
        """)
        writetemplate(self.exp_id, 'job1', """
            %{JOB.id}: %{JOB.seniority}
            %{jobs.job1.id}: %{jobs.job1.seniority}
            %{jobs.job2.id}: %{jobs.job2.seniority}
        """)
        writetemplate(self.exp_id, 'job2', """
            %{JOB.id}: %{JOB.seniority}
            %{jobs.job2.id}: %{jobs.job2.seniority}
            %{jobs.job1.id}: %{jobs.job1.seniority}
        """)
        expected = align("""
            job1: elder
            job1: elder
            job2: younger
            job2: younger
            job2: younger
            job1: elder
        """)
        ignore = output(script("mkexp "+self.exp_id+".config"))
        result = readfile(join("test", "experiments", self.exp_id,
                               self.exp_id+".job1"))
        result += readfile(join("test", "experiments", self.exp_id,
                                self.exp_id+".job2"))
        result = align(result)
        self.assertMultiLineEqual(expected, result)


if __name__ == '__main__':
    unittest.main()
