//
//  ChatGPTView.swift
//  muse
//
//  Created by Alyssa Foglia on 10/14/23.
//

import SwiftUI

struct ChatGPTView: View {
    @State var promttf = ""
    @State var Answer = ""
    @State var degrees = 0.0
    @State private var musicRec = ""
    @State var isBouncing = false
    @State var bounceCount = 0 // Counter for the number of bounces
    
    let maxBounces = 3 // Set the maximum number of bounces
    
    let theopenaiclass = OpenAIConnector()
    
    var body: some View {
        VStack {
            // Headphones with bouncing effect
            VStack {
                ZStack {
                    Image("Headphones")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .scaleEffect(isBouncing ? 1.1 : 1.0) // Apply bouncing effect conditionally
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1).repeatCount(bounceCount >= maxBounces ? 0 : 1, autoreverses: true)) {
                                isBouncing = true
                            }
                        }
                    .frame(maxHeight: 200) // Ensure a fixed height for the bouncing image
                }
            }

            Spacer()

            // Answer text and YouTube button
            ZStack {
                Text(Answer)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .frame(width: 300, height: 200)
                    .background(Rectangle().fill(Color.white))

                if Answer.count != 0 {
                    Image("youtube")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:50,height: 50)
                        .onTapGesture{
                        if let encodedAnswer = Answer.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            let youtubeURL = "https://www.youtube.com/results?search_query=\(encodedAnswer)"
                            if let url = URL(string: youtubeURL) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .offset(y: 100) // Position the button below the answer text
                }
            }

            Spacer()

            // Text field and Enter button
            VStack {
                TextField("What music are you feeling today?", text: $promttf)
                    .padding()
                    .background(Color.gray.opacity(0.3).cornerRadius(10))
                    .foregroundColor(.black)
                    .frame(maxHeight: 50) // Ensure a fixed height for the text field

                Button(action: {
                    Answer = theopenaiclass.processPrompt(prompt: "Name a specific song recommendation based on the prompt:\(promttf)")!
                    promttf = ""
                    bounceCount += 1 // Increment the bounce counter
                }, label: {
                    Text("Enter")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.cornerRadius(10))
                        .foregroundColor(.white)
                })
                .frame(maxHeight: 50) // Ensure a fixed height for the button
            }
        }
        .padding()
    }
}

// ... Your OpenAIConnector and related structs here

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
        , maxRecs: Int=1) -> Optional<String> {
        
        var request = URLRequest(url: self.openAIURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.openAIKey)", forHTTPHeaderField: "Authorization")
        let httpBody: [String: Any] = [
            "prompt" : prompt,
            "max_tokens" : 100,
            "n" : maxRecs
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

