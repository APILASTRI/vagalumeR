#' @name lyrics
#' @author Bruna Wundervald, \email{brunadaviesw@ufpr.br}.
#' @export
#' @title Lyrics of a song.
#' @description Gives the lyrics text of a song and the translation text,
#'    when the language of the song its not Portuguese.
#' @param name The name of the artist/band.
#' @return \code{lyrics} returns a data.frame with information
#'     about the artist, the song and the texts.
#' @details The variables returned by the function are extracted with
#'     the Vagalume API.
#' @examples
#'
#' identifier <- "A-Day-In-The-Life"
#' artist <- "the-beatles"
#' type <- "name"
#' lyrics(identifier, type, artist)
#'
#' identifier <- "3ade68b4gdc96eda3"
#' type <- "id"
#' lyrics(identifier, type, artist)
#'

library(plyr)
library(stringr)
library(curl)

lyrics <- function(identifier, type, artist){
  if(type == "id"){
    req <-httr::GET(paste("https://api.vagalume.com.br/search.php?musid=",identifier,"&apikey={key}"))
  }
  if(type == "name"){
    req <- httr::GET(paste("https://api.vagalume.com.br/search.php?art=",artist,"&mus=",identifier,"&extra=relmus&apikey={key}"))
  }

  cont <- httr::content(req)

  l <- lapply(cont$mus, "[", c("id", "name", "lang", "text"))
  l <- ldply(l, data.frame)

  mus <- data.frame(id = cont$art$id,
                    name = cont$art$name,
                    song.id = l$id,
                    song = l$name,
                    language = l$name,
                    text = l$text)
  mus$text <- as.character(mus$text)
  mus$text <- str_replace_all(mus$text, "[\n]" , " ")

  if(cont$mus[[1]]$lang > 1){
    tr <- lapply(cont$mus[[1]]$translate, "[", c("text"))
    tr <- ldply(tr, data.frame)
    mus <- data.frame(mus, tr$text)
    mus$tr.text <- as.character(mus$tr.text)
    mus$tr.text <- str_replace_all(mus$tr.text, "[\n]" , " ")
  }

  return(mus)
}