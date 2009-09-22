__license__   = 'GPL v3'
__copyright__ = '2008, Kovid Goyal <kovid at kovidgoyal.net>'

'''
Fetch Die Zeit.
'''

from calibre.web.feeds.news import BasicNewsRecipe


class ZeitDe(BasicNewsRecipe):

    title = 'Die Zeit Nachrichten'
    description = 'Die Zeit - Online Nachrichten'
    language = 'de'
    lang = 'de_DE'

    __author__ = 'Martin Pitt and Suajta Raman'
    use_embedded_content   = False
    max_articles_per_feed = 40
    remove_empty_feeds = True
    no_stylesheets = True
    encoding = 'utf-8'


    feeds =  [
               ('Politik', 'http://newsfeed.zeit.de/politik/index'),
               ('Wirtschaft', 'http://newsfeed.zeit.de/wirtschaft/index'),
               ('Meinung', 'http://newsfeed.zeit.de/meinung/index'),
               ('Gesellschaft', 'http://newsfeed.zeit.de/gesellschaft/index'),
               ('Kultur', 'http://newsfeed.zeit.de/kultur/index'),
               ('Wissen', 'http://newsfeed.zeit.de/wissen/index'),
             ]

    extra_css = '''
                .supertitle{color:#990000; font-family:Arial,Helvetica,sans-serif;font-size:xx-small;}
                .excerpt{font-family:Georgia,Palatino,Palatino Linotype,FreeSerif,serif;font-size:large;}
                .title{font-family:Arial,Helvetica,sans-serif;font-size:large}
                .caption{color:#666666; font-family:Arial,Helvetica,sans-serif;font-size:xx-small;}
                .copyright{color:#666666; font-family:Arial,Helvetica,sans-serif;font-size:xx-small;}
                .article{font-family:Georgia,Palatino,Palatino Linotype,FreeSerif,serif;font-size:x-small}
                .headline iconportrait_inline{font-family:Arial,Helvetica,sans-serif;font-size:x-small}
                '''
    filter_regexps = [r'ad.de.doubleclick.net/']
    keep_only_tags = [
                        dict(name='div', attrs={'class':["article"]}) ,
                         ]
    remove_tags = [
                    dict(name='link'), dict(name='iframe'),dict(name='style'),
                    dict(name='div', attrs={'class':["pagination block","pagenav","inline link"] }),
                     dict(name='div', attrs={'id':["place_5","place_4"]})
                  ]

    def get_article_url(self, article):

          url = article.get('guid', None)

          if 'video' in url or 'quiz' in url :

              url = None

          return url

    def preprocess_html(self, soup):
        soup.html['xml:lang'] = self.lang
        soup.html['lang']     = self.lang
        mtag = '<meta http-equiv="Content-Type" content="text/html; charset=' + self.encoding + '">'
        soup.head.insert(0,mtag)

        return soup

    #def print_version(self,url):
    #    return url.replace('http://www.zeit.de/', 'http://images.zeit.de/text/').replace('?from=rss', '')

