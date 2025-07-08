# library(tidyverse)
# library(readxl)
# library(glue)

# Excel dosyasını oku
df <- read_excel("content/publication/mypubs_2025_07.xlsx") |> 
  mutate(authors = str_remove_all(authors, "\\*"),
         kunye = str_squish(kunye)) 

# Dosyaları oluşturmak için istenen klasör yolunu tanımla
output_folder <- "content/publication/"
dir.create(output_folder, showWarnings = FALSE)

# Her bir satır için döngü oluştur
for (i in 1:nrow(df)) {
  # Satır bilgilerini al
  row <- df[i, ]
  
  # Klasör ismi ve kısa başlık oluştur
  date <- paste0(row$year, "-01-01")
  short_title <- str_replace_all(row$title, "[:punct:]", "") %>% str_trunc(30, "right", ellipsis = "")
  
  folder_path <- glue("{output_folder}{date}_{short_title}/")
  dir.create(folder_path, showWarnings = FALSE)
  
  pubmed_url <- paste0("https://www.ncbi.nlm.nih.gov/pubmed/", row$Pubmed)
  doi_url <- paste0("https://doi.org/", row$doi)
  authors_list <- str_split(row$authors, "\\., ") |> unlist() |> str_trim() # Yazarları ayır
  authors_formatted <- paste0('"', authors_list, '"', collapse = ", ")  # Her bir yazarın ismini çift tırnak içine al ve birleştir
  
  # Markdown dosyası içeriğini oluştur
  markdown_content <- glue('
  ---
date: "{as.Date(date)}"
external_link: ""
title: "{row$title}"
authors: [{authors_formatted}]
publication_types: ["2"]
publication: {row$journal}
publication_short: {row$kunye}
image:
    caption: ""
    focal_point: ""
    preview_only: false
links:
 - icon: pubmed
   icon_pack: ai
   name: PubMed
   url: {pubmed_url} 
 - icon: doi
   icon_pack: ai
   name: DOI
   url: {doi_url} 
slides: ""
abstract: ""
abstract_short: ""
tags: []
categories: 
  - {row$categories}
featured: false
url_pdf: ""
url_code: ""
url_dataset: ""
url_project: ""
url_slides: ""
url_source: ""
url_video: ""
---
                             ')
    
    # Dosya ismini oluştur
  file_name <- glue("{folder_path}index.md")
  
    # Markdown dosyasını yaz
    writeLines(markdown_content, file_name)
}

