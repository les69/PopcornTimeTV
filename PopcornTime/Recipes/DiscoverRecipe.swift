

import TVMLKitchen
import PopcornKit

public class DiscoverRecipe: RecipeType {
    private var currentPage = 1
    public var minimumRating = 0
    public var sortBy = "date_added"
    public var genre = ""
    
    public let theme = DefaultTheme()
    public var presentationType = PresentationType.Default
    var fetchType: FetchType! = .Movies
    
    let title: String
    let movies: [Movie]!
    let shows: [Show]!
    
    init(title: String, movies: [Movie]? = nil, shows: [Show]? = nil) {
        self.title = title
        self.movies = movies
        self.shows = shows
    }
    
    public var xmlString: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
        xml += "<document>"
        xml += template
        xml += "</document>"
        return xml
    }
    
    public var popularMovies: String {
        let mapped: [String] = movies.map {
            return $0.lockUp
        }
        return mapped.joinWithSeparator("\n")
    }
    
    public var latestMovies: String {
        let mapped: [String] = movies.map {
            return $0.lockUp
        }
        return mapped.joinWithSeparator("\n")
    }

    
    func buildShelf(title: String, content: String) -> String {
        var shelf = "<shelf><header><title>"
        shelf += title
        shelf += "</title></header><section>"
        shelf += content
        shelf += "</section></shelf>"
        return shelf
    }
    
    public var template: String {
        var xml = ""
        var shelfs = ""
        if let file = NSBundle.mainBundle().URLForResource("DiscoverRecipe", withExtension: "xml") {
            do {
                xml = try String(contentsOfURL: file)
                xml = xml.stringByReplacingOccurrencesOfString("{{TITLE}}", withString: title)
                
                if popularMovies.characters.count > 10 {
                    shelfs += self.buildShelf("Popular Movies", content: popularMovies)
                    shelfs += self.buildShelf("Latest Movies", content: latestMovies)
                    xml = xml.stringByReplacingOccurrencesOfString("{{SHELFS}}", withString: shelfs)
                }

            } catch {
                print("Could not open Catalog template")
            }
        }
        return xml
    }
    
    public func highlightLockup(page: Int, callback: (String -> Void)) {
        var data = ""
        let semaphore = dispatch_semaphore_create(0)
        if self.currentPage != page {
            switch self.fetchType! {
            case .Movies:
                NetworkManager.sharedManager().fetchMovies(limit: 50, page: page, quality: "1080p", minimumRating: self.minimumRating, queryTerm: nil, genre: self.genre, sortBy: self.sortBy, orderBy: "desc") { movies, error in
                    if let movies = movies {
                        let mapped: [String] = movies.map { movie in
                            movie.lockUp
                        }
                        data = mapped.joinWithSeparator("")
                        dispatch_semaphore_signal(semaphore)
                    }
                }
            case .Shows:
                let manager = NetworkManager.sharedManager()
                manager.fetchShowPageNumbers { pageNumbers, error in
                    if let _ = pageNumbers {
                        // this is temporary limit until solve pagination
                        manager.fetchShows([page], sort: self.sortBy, genre: self.genre) { shows, error in
                            if let shows = shows {
                                let mapped: [String] = shows.map { show in
                                    show.lockUp
                                }
                                data = mapped.joinWithSeparator("\n")
                                dispatch_semaphore_signal(semaphore)
                            }
                        }
                    }
                }
            }
            self.currentPage = page
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        callback(data)
    }
    
}
