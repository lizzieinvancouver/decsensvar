Started 28 August 2025


## Emails about new draft (April 2026)

See also: notposting/emails

* 14 April 2026 email 1:

 See attached. I added a bib and added/replaced some figures including Charrier et al. I also did some edits for flow and clarity. Again, I only edited up to the references.

    I kept the common lilac. The chineses look similar but are noiser require more smoothing, which make the plots look less nonlinear.
    done
    done
    I would just cut the first section `Summary of analytical solution.` (pages 11 to 14). You just need 15- 23, Alternative approaches (which could just be a section called additional tables), sketch of theoretical  results, and additional figures.
    done


Re chilling, that's your call since I can't really speak for the biology. I mentioned that the experiment holds photoperiod and chilling fixed and still sees the nonlinear relationship predicted by the theory. I also point out in the conclusion

* 14 April 2026 email 2: 
Sorry—in addition I meant to mention that I used the attached data [dwsl.csv] for Charrier with datasetID "charrier11" and study "exp2". Let me know if I should use the data you linked instead. 

* 8 April 2026

 Thanks Lizzie! Attached are some edits up until the references. The major change was limiting the analysis to purple lilac but updated the historic sites to 2025  (see below). To answer your questions.

   1.  I think the most rigorous analysis would use a single species with the same full bloom definition (e.g. vulgaris up to 2010). If you want to include results up to today, it might be reasonable to only use sites that participated before 2010—which givens about 10,000 observations. In that case, including/excluding 2010-2025 doesn't change the analysis. (Would it be better to use the chinensis clones?)
  2.   I wrote it with rmarkdown which I guess took my bib file and hard coded the bib items at the end. I added the natbib package so \cite should now link to the references. You can give me your bib if you want.
    I changed the threshold to tau. phi is also fine. You can just find and replace tau with phi.
 3.    That's fine with me. In 2021, we derived the mean and showed in was nonlinear. In this paper, we derive the asymptotic distribution for large tau. Re shortening the Appendix: Is everything after the references (i.e. "Summary fo analytical solution") part of the appendix? I can combine this with the theoretical results.
  4.   See marginal plots attached using data from 1955-2025 as described in 1. (I limited the analysis to vulgaris with sites that started participating before 2010, about 10,616 observations. I changed the angle and increased the smoothing (set gamma to 3) to better see the trends.



## Older ...

### Meeting: 23 September 2025

1. Code from him ...
* What is C4 f(x)? It's the SE of the SD. 
* Why not also do Kyoto for cherries? (He will add.)
* Should I also try temporal windows? 
* Fagsyl: Why different than supp? 
2. Paper from him ...
* I like the idea of using experiments and observational data ... how do we use the experiments? 
* 'Plants evolved to minimize variance produced by microclimate in a population' -- add in ref to counter and co-gradient... 
* 'Winter' vs. 'spring' (I should ask Ben Cook)
* Experiments need to include temperature variation! Charrier is not great, but they see clones bloom far apart which is expected from constant temperatures (like winter)
* Plants take advantage of 'superconsistency' (plants are like statisticians)
* Asympotatically, the start of bloom does not matter (we were discussing Gusewell)
* We assume the temperature curve shifts up... 
* Variance effects are due to thresholding on 0 and autocorrelation (do we need it?)
* Differente effects are signal noise ... in spring the signal grows but the noise does not, in the winter the signal and noise are similar. 
* What is the data underlying the conceptual figure? It's simulated .... Maybe he could fit to the climate data (we discussed, he was semi-open to it)
* We're talking about WITHIN year variance now (that's all the current math), not between year variance (which is what I looked at before) ... we're conditioning on small temperatures in current observational work so we're assuming it works as a proxy for within-year. 
3. Misc
* Should we discuss with Gelman? I will mention it to him. 
4. The Bayesian model always works! (The one from EFI.)
* See here: https://github.com/eco4cast/Statistical-Methods-Seminar-Series/tree/main/auerbach-randomwalks

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