## title: figures for selecting time period
## author: trond
## date: 26.05

library(ggplot2)
library(data.table)

treatment_vec <- c(rep('pre', 3), 'treatment', rep('post', 8))
period_dt <- melt(data.table(year = seq(2004, 2018),
                             id_1 = c(treatment_vec, rep(NA, 2018 - 2004 - 11)),
                             id_2 = c(rep(NA, 1), treatment_vec, rep(NA, 2018 - 2004 - 1 - 11)),
                             id_3 = c(rep(NA, 2), treatment_vec, rep(NA, 2018 - 2004 - 2 - 11)),
                             id_4 = c(rep(NA, 3), treatment_vec)
                        ),
                  id.vars = 'year'
                  )[!is.na(value),
                    s := seq(-3, 8),
                    by = variable
                    ]


ggplot(period_dt, aes(year, variable)) +
    geom_point(aes(col = value)) +
    scale_colour_brewer(name = '', palette = 'Set1', na.value = 'transparent', na.translate = F) +
    theme_bw() +
    geom_text(aes(label = s), nudge_y = 0.2) + 
    ylab('')
ggsave('../figs/did_selection.png', width = 5, height = 3, dpi = 200)
