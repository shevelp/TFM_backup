# -------------------------
#       Data Analysis
#--------------------------

library(ggplot2)
library(Kendall)

# Distribuida
serie_1<- read.table("anu_d.dat", header = FALSE)

# Continua
serie_2 <- read.table("anu.dat", header = FALSE)

#TIME SERIES PLOT

plot <- ggplot() +
  geom_line(mapping = aes(x = serie_1$V1, y = serie_1$V4), color = "red")+
  geom_line(mapping = aes(x = serie_2$V1, y = serie_2$V4), color = "black")+
  theme_light()+
  xlab("Days") +
  ylab("Temperature at 2m")


plot(plot)

# Analysis: 

# Mean analysis: 
mean_d <- mean(serie_1$V4)
mean_c <- mean(serie_2$V4)

# Standar dev
st_d <-  sd(serie_1$V4)
st_c <-  sd(serie_2$V4)

# K-S test:
ks_dc <- ks.test(serie_1$V4, serie_2$V4)
ks_dc

#Kendall-test: significance between the different of slopes

kendal_dc <- Kendall(serie_1$V4, serie_2$V4)
kendal_dc
