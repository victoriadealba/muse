//
//  ContentView.swift
//  muse
//
//  Created by Victoria De Alba on 10/13/23.
//

import SwiftUI

struct ContentView: View {
   // @State private var start = false
    var body: some View {
        NavigationView{
            homepage()
        }
     /*   VStack {
            //header
            ZStack{
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 15))
                VStack{
                    Text("Welcome to Muse")
                        .font(.system(size: 45))
                        .foregroundColor(Color.white)
                        .bold()
                        
                    
                }
                .padding(.top,30)
            }
            .frame(width: UIScreen.main.bounds.width * 3, height:300)
            .offset(y: -100)
            
            /*Button("START"){ start.toggle()}
                .foregroundColor(Color.blue)
                .font(.title)
                .padding()
                .border(Color.blue, width:5)
                .offset(y:200)
             */
               
            //if start{
                
                    NavigationLink("START", destination: ChatGPTView())
                        .foregroundColor(Color.blue)
                        .font(.title)
                        .padding()
                        .border(Color.blue, width:5)
                        .offset(y:100)
       
            Spacer()
        }
        
    }
      */
     
}

struct homepage: View{
    @State private var start = false
    var body: some View {
        VStack {
            //header
            ZStack{
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 15))
                VStack{
                    Text("Welcome to Muse")
                        .font(.system(size: 45))
                        .foregroundColor(Color.white)
                        .bold()
                    
                    
                }
                .padding(.top,30)
            }
            .frame(width: UIScreen.main.bounds.width * 3, height:300)
            .offset(y: -100)
            
            /*Button("START"){ start.toggle()}
             .foregroundColor(Color.blue)
             .font(.title)
             .padding()
             .border(Color.blue, width:5)
             .offset(y:200)
             */
            
            //if start{
            
            NavigationLink("START", destination: ChatGPTView())
                .foregroundColor(Color.blue)
                .font(.title)
                .padding()
                .border(Color.blue, width:5)
                .offset(y:100)
            
            Spacer()
        }
    }
    }
}

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
