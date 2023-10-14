//
//  ChatGPTView.swift
//  muse
//
//  Created by Alyssa Foglia on 10/14/23.
//

import SwiftUI

/*struct ChatGPTView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
*/


struct ChatGPTView: View {
    @State var promttf = ""
    @State var Answer = ""
    @State var degrees = 0.0
    let theopenaiclass = OpenAIConnector()
    var body: some View {
        VStack {
            Image("Headphones")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            Spacer()
            if Answer.count != 0{
                Text(Answer)
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .frame(
                       width: 300,
                       height: 200
                    )
                    .background(Rectangle().fill(Color.white))
            }
            Spacer()
            ZStack{
                TextField("What music are you feeling today?",text: $promttf)
                    .padding()
                    .background(Color.gray.opacity(0.3).cornerRadius(10))
                    .foregroundColor(.black)
            }
            Button(action:{
                            Answer = theopenaiclass.processPrompt(prompt: "List 1 to 5 song recommendations:\(promttf)")!
                            promttf = ""
            }, label:{
                Text("Enter")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.cornerRadius(10))
                    .foregroundColor(.white)
            }
            )
            
                    }
        .padding()
    }
}

struct ChatGPTView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
public class OpenAIConnector {
    let openAIURL = URL(string: "https://api.openai.com/v1/engines/text-davinci-002/completions")
    var openAIKey: String {
        return ""
    }
    
    private func executeRequest(request: URLRequest, withSessionConfig sessionConfig: URLSessionConfiguration?) -> Data? {
        let semaphore = DispatchSemaphore(value: 0)
        let session: URLSession
        if (sessionConfig != nil) {
            session = URLSession(configuration: sessionConfig!)
        } else {
            session = URLSession.shared
        }
        var requestData: Data?
        let task = session.dataTask(with: request as URLRequest, completionHandler:{ (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print("error: \(error!.localizedDescription): \(error!.localizedDescription)")
            } else if data != nil {
                requestData = data
            }
            
            print("Semaphore signalled")
            semaphore.signal()
        })
        task.resume()
        
        // Handle async with semaphores. Max wait of 10 seconds
        let timeout = DispatchTime.now() + .seconds(20)
        print("Waiting for semaphore signal")
        let retVal = semaphore.wait(timeout: timeout)
        print("Done waiting, obtained - \(retVal)")
        return requestData
    }
    
    public func processPrompt(
        prompt: String
    ) -> Optional<String> {
        
        var request = URLRequest(url: self.openAIURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.openAIKey)", forHTTPHeaderField: "Authorization")
        let httpBody: [String: Any] = [
            "prompt" : prompt,
            "max_tokens" : 100
     //       "temperature": String(temperature)
        ]
        
        var httpBodyJson: Data
        
        do {
            httpBodyJson = try JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted)
        } catch {
            print("Unable to convert to JSON \(error)")
            return nil
        }
        request.httpBody = httpBodyJson
        if let requestData = executeRequest(request: request, withSessionConfig: nil) {
            let jsonStr = String(data: requestData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            print(jsonStr)
            ///
            //MARK: I know there's an error below, but we'll fix it later on in the article, so make sure not to change anything
            ///
            let responseHandler = OpenAIResponseHandler()

            return responseHandler.decodeJson(jsonString: jsonStr)?.choices[0].text
            
        }
        
        return nil
    }
}
struct OpenAIResponseHandler {
    func decodeJson(jsonString: String) -> OpenAIResponse? {
        let json = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let product = try decoder.decode(OpenAIResponse.self, from: json)
            
            return product
            
        } catch {
            print("Error decoding OpenAI API Response")
        }
        
        return nil
    }
}

struct OpenAIResponse: Codable{
    var id: String
    var object : String
    var created : Int
    var model : String
    var choices : [Choice]
}
struct Choice : Codable{
    var text : String
    var index : Int
    var logprobs: String?
    var finish_reason: String
}

public extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(
            get: { source.wrappedValue ?? nilProxy },
            set: { newValue in
                if newValue == nilProxy {
                    source.wrappedValue = nil
                }
                else {
                    source.wrappedValue = newValue
                }
        })
    }
}
