import Foundation
import RxSwift
import RxCocoa

class TopAnimeViewModel: BaseViewModel {
    let api = APIManager.shared
    
    let tabBarItem: [String] = ["Airing", "Upcoming", "By Popularity", "Favorite"]
    let topAiringAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let topUpcomingAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let topPopularityAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let topFavoriteAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    
    func loadData <T: Codable>(for endpoint: Endpoint,with topAnime: TopAnimeEnum, resultType: T.Type){
        loadingState.accept(.loading)
        
        api.fetchRequest(endpoint: endpoint){ [weak self] (response: Result<T, Error>) in
            guard let self = self else { return }
            
            switch response{
            case .success(let data):
                switch endpoint {
                case .getTopAnime:
                    if let data = data as? AnimeResponse {
                        self.responseData(data: data, with: topAnime)
                    }
                    self.loadingState.accept(.finished)
                    break
                default:
                    self.loadingState.accept(.finished)
                    break
                }
                break
            case .failure:
                self.loadingState.accept(.failed)
            }
        }
    }
    
    func responseData(data: AnimeResponse, with topAnime: TopAnimeEnum){
        switch topAnime {
        case .airing:
            self.topAiringAnime.accept(data.data)
            break
        case .upcoming:
            self.topUpcomingAnime.accept(data.data)
            break
        case .popularity:
            self.topPopularityAnime.accept(data.data)
            break
        case .favorite:
            self.topFavoriteAnime.accept(data.data)
            break
        }
    }
}