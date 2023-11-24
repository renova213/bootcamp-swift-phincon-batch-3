import Foundation
import Alamofire

enum APIError: Error {
    case unauthorized
    case internalServerError
    case badRequest
    case notFound
    case confilct
    case unknownError
}

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    public func fetchRequest<T: Codable>(endpoint: Endpoint, completion: @escaping(Result<T, Error>)-> Void){
        
        AF.request(endpoint.urlString(),
                   method: endpoint.method(),
                   parameters: endpoint.parameters,
                   encoding: endpoint.encoding,
                   headers: endpoint.headers).validate().responseDecodable(of: T.self) { response in
            
            switch response.result {
            case .success(let decodedObject):
                completion(.success(decodedObject))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func fetchRequestBase2<T: Codable>(endpoint: Endpoint, completion: @escaping(Result<T, Error>)-> Void){
            
        AF.request(endpoint.urlString2(),
                   method: endpoint.method(),
                   parameters: endpoint.parameters,
                   encoding: endpoint.encoding,
                   headers: endpoint.headers).validate().responseDecodable(of: T.self) { response in
        
            switch response.result {
            case .success(let decodedObject):
                completion(.success(decodedObject))
                
            case .failure(let error):
                completion(.failure(error))
        }
    }
}
}
