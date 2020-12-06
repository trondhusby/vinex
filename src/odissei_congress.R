## title: figures for odissei congress 2020
## author: trond
## date: 20.11.2020

## house keeping
library(purrr)
library(data.table)
library(ggplot2)
library(xtable)

## read data
cross_sec_dt <- fread('../data/cross_sec_sumstats.csv')[,
                                                        lapply(.SD,
                                                               function(x) {
                                                                   round(x, 2)
                                                               }),
                                                        by = variable]
cross_sec_dt[is.na(cross_sec_dt)] <- ''


longit_sec_dt <- fread('../data/longit_sumstats.csv')


## make cross sectional table
vars_dict <- data.table(variable = c('eengezins', 'VBOOPPERVLAKTE', 'AANTALPERSHH', 'oad',
                                 'move_dist', 'dist_sg'),
                        new = c('single family', 'm2', 'household size', 'density',
                                'move distance', 'distance agglommeration')
                        )

vars <- c('single family', 'm2', 'age', 'household size', 'spouse', 'dutch',
          'children', 'density', 'move distance', 'distance agglommeration', 'N')

cross_sec_dt[vars_dict,
             new := i.new,
             on = 'variable'
             ]
cross_sec_dt[!is.na(new),
             variable := new
             ][,
               new := NULL
               ]

out_tbl <- rbind(data.table(t(c('', rep(c('mean', 'sd'),2)))),
      cross_sec_dt[variable %in% vars,  -'pval'],
      use.names = F)

out_tbl[-c(1,.N),
        ':=' (
            V2 = ifelse(V2 > V4,
                        paste0('\textcolor{red}{', V2,'}'),
                        paste0('\textcolor{blue}{', V2,'}')
                        ),
            V4 = ifelse(V4 > V2,
                        paste0('\textcolor{red}{', V4,'}'),
                        paste0('\textcolor{blue}{', V4,'}')
                        )
            )]

print(xtable(out_tbl), include.rownames=FALSE)


## figure of dependent variables
longit_sec_dt[, group := ifelse(vinex == 'Vinex', 'Treatment', 'Control')]

longit_sec_dt[,
              variable := gsub('woz', 'home value',
                               gsub('comm_dist', 'commuting distance',
                                    variable))
              ][variable == 'commuting distance',
                value := value / 1000
                ]


longit_sec_dt[time_period > -4 & !(variable == 'moved' & time_period < 1)] %>%
    dcast(., 'time_period + group + variable ~ measure', value.var = 'value') %>%
    ggplot(., aes(time_period, mean, group = group)) +
    geom_line(aes(col = group)) +
    geom_ribbon(aes(ymin = mean + 2*se, ymax = mean - 2*se), alpha = 0.2, fill = 'grey') +
    facet_wrap(~variable, scales = 'free') +
    scale_colour_brewer(palette = 'Set1', name = '') +
    ylab('value') + 
    theme_minimal()
ggsave('../figs/dep_vars.png', width = 20, height = 10, units = "cm")


