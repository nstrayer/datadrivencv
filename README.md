# datadrivencv

Ever feel a pit of dread when you need to add something to your resume or CV? You'll have to add it, then make sure the formatting didn't get messed up. What about changing to a new template/style? Better warm up your ctr-c ctrl-p fingers. 

`datadrivencv` separates the CV format from the content using spreadsheets, `RMarkdown`, and `Pagedown` packages. It's built to allow easy out-of-the-box behavior, but also to allow you to easily go beyond the defaults with customization and lack of lock-in to a given format. 


## Get up and running: 

To set yourself up with a data-driven cv, in the desired directory for your CV, run the function: 

```r
datadrivencv::use_datadriven_cv(
  full_name = "Nick Strayer",
  data_location = "https://docs.google.com/spreadsheets/d/14MQICF2F8-vf8CKPF1m4lyGKO6_thG-4aSwat1e2TWc",
  pdf_location = "https://github.com/nstrayer/cv/raw/master/strayer_cv.pdf",
  html_location = "nickstrayer.me/cv/",
  source_location = "https://github.com/nstrayer/cv"
)
```

With your details filled in the appropriate spaces. See more about what each position is with `?datadrivencv::use_datadriven_cv`.

This will build three files in your current working directory:

- `cv.Rmd`: An RMarkdown file with various sections filled in. Edit this to fit your personal needs. 
- `dd_cv.css`: A custom set of CSS styles that build on the default `Pagedown` "resume" template. Again, edit these as desired.
- `render_cv.R`: Use this script to build your CV in both PDF and HTML at the same time. 

