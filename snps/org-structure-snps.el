;;; org-structure-snps.el --- org structure templates

;; Copyright (C) 2013  Thomas Alexander Gerds

;; Author: Thomas Alexander Gerds <tag@biostat.ku.dk>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Defines structure template for LaTeX
;; <La
;; for Beamer
;; <Lb
;; and several for R
;; <Rs silent block
;; <Rc code only
;; <Rr results only
;; <Rb both results and code
;; <Re like Rb but output format example instead of raw
;; <Rg graphics, prompts for file name
;; <Rt inline text: paste R results into the middle of a sentence 

;; 
;;; Code:
;; (setq org-structure-template-alist nil)

;;{{{ Latex & Beamer
(add-to-list
 'org-structure-template-alist
 '("Lf" "#+LaTeX: \\blfootnote{}"))
(add-to-list
 'org-structure-template-alist
 `("La" ,(concat "#+TITLE: 
#+LANGUAGE:  en
#+OPTIONS:   H:3 num:t toc:nil \\n:nil @:t ::t |:t ^:t -:t f:t *:t <:t
#+OPTIONS:   TeX:t LaTeX:t skip:nil d:nil todo:t pri:nil tags:not-in-toc author:t
#+LaTeX_CLASS: org-article
#+LaTeX_HEADER:\\usepackage{authblk}
#+LaTeX_HEADER:\\author{"
user-full-name
"}
#+PROPERTY: session *R*
#+PROPERTY: cache yes")))

(add-to-list
 'org-structure-template-alist
 `("Lb" ,(concat "#+TITLE: 
#+Author: " user-full-name 
"\n#+DATE: 
#+EMAIL:" user-mail-address
"\n#+LANGUAGE:  en
#+OPTIONS: H:3 num:t toc:nil \\n:nil @:t ::t |:t ^:t -:t f:t *:t <:t
#+OPTIONS: TeX:t LaTeX:t skip:nil d:nil todo:t pri:nil tags:not-in-toc
#+INFOJS_OPT: view:nil toc:nil ltoc:t mouse:underline buttons:0 path:http://orgmode.org/org-info.js
#+SELECT_TAGS: export
#+EXCLUDE_TAGS: noexport
#+LINK_UP:
#+LINK_HOME: 
#+startup: beamer
#+LaTeX_CLASS: beamer
#+Latex_header:\\institute{Department of Biostatistics, University of Copenhagen}
#  #+ LaTeX_class_options: [handout]
#+LaTeX_HEADER:\\usepackage{natbib}
#+LaTeX_HEADER: \\usepackage{attachfile}
#+LaTeX_HEADER: \\usepackage{array}
#+LATEX_CMD: pdflatex
#+LaTeX_HEADER: \\usetheme[numbers]{Dresden}
#+LaTeX_HEADER: \\setbeamercolor{structure}{fg=white}
#+LaTeX_HEADER: \\setbeamercolor*{palette primary}{fg=black,bg=white}
#+LaTeX_HEADER: \\setbeamercolor*{palette secondary}{use=structure,fg=white,bg=white}
#+LaTeX_HEADER: \\setbeamercolor*{palette tertiary}{use=structure,fg=white,bg=structure.fg!50!black}
#+LaTeX_HEADER: \\setbeamercolor*{palette quaternary}{fg=white,bg=black}
#+LaTeX_HEADER: \\setbeamercolor{item}{fg=red}
#+LaTeX_HEADER: \\setbeamercolor{subitem}{fg=orange}
#+LaTeX_HEADER: \\setbeamercolor*{sidebar}{use=structure,bg=structure.fg}
#+LaTeX_HEADER: \\setbeamercolor*{palette sidebar primary}{use=structure,fg=structure.fg!10}
#+LaTeX_HEADER: \\setbeamercolor*{palette sidebar secondary}{fg=white}
#+LaTeX_HEADER: \\setbeamercolor*{palette sidebar tertiary}{use=structure,fg=structure.fg!50}
#+LaTeX_HEADER: \\setbeamercolor*{palette sidebar quaternary}{fg=white}
#+LaTeX_HEADER: \\setbeamercolor*{titlelike}{parent=palette primary}
#+LaTeX_HEADER: \\setbeamercolor*{separation line}{}
#+LaTeX_HEADER: \\setbeamercolor*{fine separation line}{}
#+LaTeX_HEADER: \\setbeamertemplate{footline}[frame number]
#+LaTeX_HEADER: \\setbeamertemplate{navigation symbols}{}
#+LaTeX_HEADER: \\setbeamertemplate{subitem}[circle]
#+LaTeX_HEADER: \\newcommand{\\sfootnote}[1]{\\renewcommand{\\thefootnote}{\\fnsymbol{footnote}}\\footnote{#1}\\setcounter{footnote}{0}\\renewcommand{\\thefootnote}{\\arabic{foot note}}}
#+LaTeX_HEADER:\\makeatletter\\def\\blfootnote{\\xdef\\@thefnmark{}\\@footnotetext}\\makeatother
#+LATEX_HEADER: \\RequirePackage{fancyvrb}
#+LATEX_HEADER: \\DefineVerbatimEnvironment{verbatim}{Verbatim}{fontsize=\\small,formatcom = {\\color[rgb]{0.5,0,0}}}
#+SELECT_TAGS: export
#+EXCLUDE_TAGS: noexport
#+PROPERTY: session *R*
#+PROPERTY: cache yes")))


;; Shrinking a slide
(add-to-list
 'org-structure-template-alist
 '("Bs" " :PROPERTIES:
 :BEAMER_opt: shrink=25
 :END:"))
;;; Two column slides
(add-to-list
 'org-structure-template-alist
 '("Bc" "
*** Column 1                                          :B_ignoreheading:
    :PROPERTIES:
    :BEAMER_env: ignoreheading
    :BEAMER_col: 0.5
    :END:

*** Column 2                                            :B_ignoreheading:
    :PROPERTIES:
    :BEAMER_col: 0.5
    :BEAMER_env: ignoreheading
    :END:
    "))

;;}}}
;;{{{ R code objects
(add-to-list
 'org-structure-template-alist
 '("Rs" "#+BEGIN_SRC R :results silent  :exports none :session *R* :cache yes \n?\n#+END_SRC"))
(add-to-list
 'org-structure-template-alist
 '("Rb" "#+BEGIN_SRC R :exports both :results output raw  :session *R* :cache yes \n?\n#+END_SRC"))

(add-to-list
 'org-structure-template-alist
 '("Re" "#+BEGIN_SRC R :exports both :results output :session *R* :cache yes \n?\n#+END_SRC"))

(add-to-list
 'org-structure-template-alist
 '("Rc" "#+BEGIN_SRC R :exports code :results silent  :session *R* :cache yes \n?\n#+END_SRC"))
(add-to-list
 'org-structure-template-alist
 '("Rl" "#+BEGIN_SRC R  :results output latex   :exports results  :session *R*\n?\n#+END_SRC"))
(add-to-list
 'org-structure-template-alist
 '("Ro" "#+BEGIN_SRC R  :results output raw  :exports results  :session *R* :cache yes \n?\n#+END_SRC"))
(add-to-list
 'org-structure-template-alist
 '("Rv" "#+BEGIN_SRC R  :results value  :exports results  :session *R* :cache yes \n?\n#+END_SRC"))
(add-to-list
 'org-structure-template-alist
 '("Rr" "#+BEGIN_SRC R  :results output raw  :exports results  :session *R* :cache yes \n?\n#+END_SRC"))
(add-to-list
 'org-structure-template-alist
 '("Rg" "#+BEGIN_SRC R :results graphics  :file %file :exports results :session *R* :cache yes \n?\n#+END_SRC"))
(add-to-list
 'org-structure-template-alist
 '("RG" "#+BEGIN_SRC R :results graphics  :file filename :exports results :session *R* :cache yes \n?\n#+END_SRC"))
(add-to-list
 'org-structure-template-alist
 '("Rt" "SRC_R{}"))

;;}}}



;;{{{ graphics
(add-to-list
 'org-structure-template-alist
 '("Lw" "#+ATTR_LATEX: width=0.7\\textwidth"))

(add-to-list
 'org-structure-template-alist
 '("d" "#+ATTR_LATEX: width=0.5\\textwidth\n\n#+BEGIN_SRC dot :file figure1.png :cmdline -Kdot -Tpng \n digraph overview{\"A\" -> {\"b\",\"c\"};}?\n#+END_SRC"))
;;}}}

(provide 'org-structure-snps)
;;; org-structure-snps.el ends here
