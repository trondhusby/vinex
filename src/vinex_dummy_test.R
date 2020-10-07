## title: VINEX test
## date: 29.04.2020
## author: Trond

## house keeping
library(data.table)
library(gnm)

set.seed(123)

## create random data
len_dt <- 10

test_dt <- data.table(i = seq(1, len_dt),
           y = sample(c(0,1), len_dt, replace = T),
           t = sample(seq(1996, 1998), len_dt, replace = T),
           lft = sample(seq(30, 50), len_dt),
           ink = sample(seq(4000, 10000), len_dt)
           )

## dynamic regression model
out1 <- glm(y ~ factor(t)*(lft + ink), data = test_dt)
out2 <- gnm(y ~ Mult(factor(t), as.numeric(lft)) +
                Mult(factor(t), as.numeric(ink)),
            data = test_dt)

