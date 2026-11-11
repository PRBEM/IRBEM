# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys

sys.path.append(os.path.abspath("./_ext"))

# -- Project information -----------------------------------------------------

project = 'IRBEM'
copyright = '2024, PRBEM'
author = 'PRBEM'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = ['routine']

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'pydata_sphinx_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']
html_css_files = ['css/irbem.css']
html_theme_options = {
        "navigation_depth": 2,
        "navbar_end": ["navbar-icon-links"],
        "secondary_sidebar_items": ["page-toc"],
        "external_links": [
            {"name" : "Github page", "url" : "https://github.com/PRBEM/IRBEM"},
            {"name" : "PRBEM Website", "url" : "https://prbem.github.io"},
            ],
        "icon_links": [
            {
                "name": "GitHub",
                "url": "https://github.com/PRBEM/IRBEM",
                "icon": "fa-brands fa-square-github",
                "type": "fontawesome",
                },
            ],
        }

html_sidebars = {
    "irbem-routines" : [],
}
