//
//  ContentView.swift
//  muse
//
//  Created by Victoria De Alba on 10/13/23.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        NavigationView{
            homepage()
        }
}

struct homepage: View{
    var body: some View {
        
        VStack {
            //header
            
                Spacer()
                Image("Cover")
                    .resizable()
                    .frame(width: 550, height: 1000, alignment: .top)
                    .offset(x:50,y:30)
                    .overlay( NavigationLink(">", destination: ChatGPTView())
                        .foregroundColor(Color.white)
                        .font(.title)
                        .padding()
                              //.border(Color.white, width:5)
                        .offset(x: 140, y:350))
                
                    .padding(.top,30)
            }
        }
    }
}

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
