__Example data and code for:__

Jan Clemens, Mala Murthy (2021) __Quadratic and adaptive computations yield an efficient representation of song in Drosophila auditory receptor neurons_, [preprint](https://www.biorxiv.org/content/10.1101/2021.05.26.445391)

Requires matlab. See [github.com/janclemenslab/glm_utils](https://github.com/janclemenslab/glm_utils/blob/master/demo/quadratic_filter.ipynb) for code that uses python’s scikit-learn to fit a quadratic filter.

__Directory structure:__
- `src/`: Source code. Contains code from [Park and Pillow (2011)](http://pillowlab.princeton.edu/code_ALD.html).
- `dat/`: Data files containing responses for different types of acoustic stimuli used in the paper.
- `res/`: Data files containing the results of model fitting.
- `fig/`: Figures with expected results.
- `fit_model.m`: Loads stimuli-response data from `dat/`, fits the quadratic&adaptive model, and saves results to `res/`.
- `plot_predictions.m`, `plot_eigendecomposition.m`: Loads model from ‘res/‘ and plots model predictions and the eigenvalue decomposition of the quadratic filter. See ‘fig/` for expected results.

__Usage:__
- run `fit_models.m` twice, with the `filename` in lines 4-5 set to `dat/noise_20160311_8.mat` and `dat/step_20140625_1.mat`, respectively. This will fit the model for two variants of the noise stimulus and save the results in `res/`.
- To plot the results, run `plot_predictions.m` and `plot_eigendecomposition.m`. This will load and plot the results from `res/`.
