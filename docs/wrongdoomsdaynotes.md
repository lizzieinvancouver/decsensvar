Started 28 August 2025



### Meeting: 2 September 2025

* Keep appealing to the CLT but add enough structure to problem that you can predict stuff
* Sounds good to me!
* In statistics, information is defined as the inverse of variation
* ESS is the ratio of the variances 
* Bloom dates will tell us less about the underlying biology (field will need to rely more on experiments)
* You don't have to get the temperature right, it just needs to be consistently off
* People were focusing on the mean; they should be focusing on the variance

I should ask about:
* Getting figures: Can he pick two years for the conceptual?
* You're sending R code for boxplot/quantile figure (SE of the SE is okay? Andrew is on paper, let's write something up and see if he is interested)
* Include the Bayesian model! 
* Him getting climate data (ERA5: The API is easy enough to use, how to request ERA5 for many years (you can only request one year at a time?))  
* GitHub name: jauerbach
* Meeting again when? 

### Email exhange 28 August 2025 regarding BES abstract

Me: Good query on what's breaking down ... I am not sure. I guess the model
does still work but is just accumulating too quickly, such that rules of
the normal don't apply any more --- so then it sort of breaks the model,
no? It's breaks the assumption of normality? But I guess plants don't
use that, we do ... (is it Friday yet?).

JA: Yea, we're still assuming the thermal sum model. The problem as I see it is that warming climates are increasing variation in the bloom date among plants at the same site due to location, height, shade, etc. (We would expect warming climates to reduce variation, but the opposite is occurring.) As a result, knowing a plant's GDD is telling you less about the bloom date, and knowing the bloom date tells you less about a plant's GDD.

The main culprit is the thresholding of temperatures at 0. Bloom dates in the spring are not really affected since most accumulation is not truncated by the threshold. In contrast, bloom dates in late winter are driven by warming days separated by strings of days with truncated temperatures at or below 0. Those zeros add to the variance of the bloom date. They also lead to a breakdown of the CLT. Autocorrelation exaggerates the strings of 0's.

Me: Basically all plant and animal life has this sort of thresholding (think
enzyme kinectic curves) -- the exact number varies (0, 10 etc.) but the
presence of a thresholding temperature doesn't. I think one question is
how much the binning of time matters -- for plants and GDD you can make
the case that day is a relevant unit, but for other processes it might
be a much smaller bin and so less of an effect?

JA: I didn't think of that. There could be an issue if you use average or midrange daily temperature as a measure of the cumulative temperature but neglect the fact that part of the day is below the threshold. I don't think it changes anything, but I'll think about it.