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
                        .foregroundColor(Color(red: 0.165, green: 0.337, blue: 0.529))
                        .font(.largeTitle)
                        .padding()
                              //.border(Color.white, width:5)
                        .offset(x: 115, y:325))
                        
            
                    .overlay(Circle()
                        .position(x:150,y:360)
                        .foregroundColor(Color.white)
                        .opacity(0.4)
                        .frame(width: 73.0, height: 67.0))
                        

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
