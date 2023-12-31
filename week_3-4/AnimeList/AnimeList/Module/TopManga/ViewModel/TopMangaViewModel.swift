import Foundation
import RxSwift
import RxCocoa

class TopMangaViewModel: BaseViewModel {
    let tabBarItem: [String] = ["Publishing", "Upcoming", "By Popularity", "Favorite"]
    let topPublishingManga = BehaviorRelay<[MangaEntity]>(value: [])
    let topUpcomingManga = BehaviorRelay<[MangaEntity]>(value: [])
    let topPopularityManga = BehaviorRelay<[MangaEntity]>(value: [])
    let topFavoriteManga = BehaviorRelay<[MangaEntity]>(value: [])
    
    func loadData <T: Codable>(for endpoint: Endpoint, with topManga: TopMangaEnum, resultType: T.Type){
        loadingState.accept(.loading)
        
        api.fetchRequest(endpoint: endpoint){ [weak self] (response: Result<T, Error>) in
            guard let self = self else { return }
            
            switch response{
            case .success(let data):
                if let data = data as? MangaResponse {
                    self.responseData(data: data, with: topManga)
                    self.loadingState.accept(.finished)
                    
                    if(data.data.isEmpty){
                        self.loadingState.accept(.empty)
                    }
                }
                break
            case .failure(let error):
                if let error = error as? CustomError {
                    self.errorMessage.accept(error.message)
                }
                self.loadingState.accept(.failed)
            }
        }
    }
    
    private func responseData(data: MangaResponse, with topManga: TopMangaEnum){
        switch topManga {
        case .publishing:
            self.topPublishingManga.accept(data.data)
            break
        case .upcoming:
            self.topUpcomingManga.accept(data.data)
            break
        case .popularity:
            self.topPopularityManga.accept(data.data)
            break
        case .favorite:
            self.topFavoriteManga.accept(data.data)
            break
        }
    }
}
