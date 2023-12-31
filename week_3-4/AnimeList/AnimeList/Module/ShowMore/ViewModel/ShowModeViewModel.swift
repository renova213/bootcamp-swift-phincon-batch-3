import Foundation
import RxSwift
import RxCocoa

class ShowMoreViewModel: BaseViewModel {
    static let shared = ShowMoreViewModel()
    
    let showMoreAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    
    func loadData <T: Codable>(for endpoint: Endpoint, resultType: T.Type){
        loadingState.accept(.loading)
        
        api.fetchRequest(endpoint: endpoint){ [weak self] (response: Result<T, Error>) in
            guard let self = self else { return }
            
            switch  response{
            case .success(let data):
                let data = data as? AnimeResponse
                self.showMoreAnime.accept(data?.data ?? [])
                self.loadingState.accept(.finished)
                break
            case .failure(let error):
                if let error = error as? CustomError {
                    self.errorMessage.accept(error.message)
                }
                self.loadingState.accept(.failed)
                break
            }
        }
    }
}
