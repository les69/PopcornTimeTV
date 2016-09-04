

import PopcornKit

extension Movie {
    
    var carousel: String {
        var string = "<lockup actionID=\"showMovie»\(id)\" playActionID=\"playMovieById»\(id)\">"
        string += "<img class=\"img\" src=\"\(mediumCoverImage)\" width=\"1740\" height=\"500\" />"
        string += "<title style=\"tv-text-highlight-style: marquee-and-show-on-highlight;\">\(title.cleaned)</title>"
        string += "</lockup>"
        return string
    }

}
