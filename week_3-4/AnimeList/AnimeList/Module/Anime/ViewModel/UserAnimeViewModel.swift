import Foundation
import RxSwift
import RxCocoa

class UserAnimeViewModel {
    static let shared = UserAnimeViewModel()
    
    var userAnime = BehaviorRelay<[UserAnimeEntity]>(value: [])
    let findOneUserAnime = BehaviorRelay<UserAnimeEntity?>(value: nil)
    let filterData = ["A-Z", "Z-A", "Score", "Watching Status", "Sort By"]
    
    func postUserAnime(body: UserAnimeBody, completion: @escaping((Result<StatusResponse, Error>)-> Void)) {
        let endpoint = Endpoint.postUserAnime(params: body)
        APIManager.shared.fetchRequest(endpoint: endpoint){(result: Result<StatusResponse, Error>) in
            completion(result)
        }
    }
    
    func getUserAnime(userId: Int, completion: @escaping((Bool)-> Void)) {
        let endpoint = Endpoint.getUserAnime(userId: userId)
        APIManager.shared.fetchRequest(endpoint: endpoint){(result: Result<UserAnimeResponse, Error>) in
            switch result {
            case .success(let data):
                self.userAnime.accept(data.data ?? [])
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    func updateUserAnime(body: UpdateUserAnimeBody, completion: @escaping((Result<StatusResponse, Error>)-> Void)) {
        let endpoint = Endpoint.putUserAnime(params: body)
        APIManager.shared.fetchRequest(endpoint: endpoint){(result: Result<StatusResponse, Error>) in
           completion(result)
        }
    }
    
    func deleteUserAnime(id: String, completion: @escaping((Result<StatusResponse, Error>)-> Void)) {
        let endpoint = Endpoint.deleteUserAnime(id: id)
        APIManager.shared.fetchRequest(endpoint: endpoint){(result: Result<StatusResponse, Error>) in
           completion(result)
        }
    }
    
    func findOneUserAnime(userId: Int, malId: Int, completion: @escaping((Bool)-> Void)) {
        let endpoint = Endpoint.findOneUserAnime(userId: userId, malId: malId)
        APIManager.shared.fetchRequest(endpoint: endpoint){(result: Result<FindOneUserAnimeResponse, Error>) in
            switch result {
            case .success(let data):
                if let userAnimeData = data.data{
                    self.findOneUserAnime.accept(userAnimeData)
                }
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    func sortUserAnime(index: Int){
        switch index {
        case 0:
            self.userAnime.accept(userAnime.value.sorted {$0.anime.title ?? "" < $1.anime.title ?? ""})
        break
        case 1:
            self.userAnime.accept(userAnime.value.sorted {$0.anime.title ?? "" > $1.anime.title ?? ""})
        case 2:
            self.userAnime.accept(userAnime.value.sorted {$0.userScore > $1.userScore})
        case 3:
            self.userAnime.accept(userAnime.value.sorted {$0.watchStatus < $1.watchStatus})
        default:
            break
        }
    }
}
