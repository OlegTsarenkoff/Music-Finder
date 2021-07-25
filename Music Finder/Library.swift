//
//  Library.swift
//  Music Finder
//
//  Created by Oleg Tsarenkoff on 25.07.21.
//

import SwiftUI

struct Library: View {
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button(action: {
                            print("123")
                        }, label: {
                            Image(systemName: "play.fill")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 1, green: 0.2156862745, blue: 0.3725490196, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9161354899, green: 0.9106894135, blue: 0.9203217626, alpha: 1)))
                                .cornerRadius(10)
                        })
                        
                        Button(action: {
                            print("123")
                        }, label: {
                            Image(systemName: "arrow.2.circlepath")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 1, green: 0.2156862745, blue: 0.3725490196, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9161354899, green: 0.9106894135, blue: 0.9203217626, alpha: 1)))
                                .cornerRadius(10)
                        })
                    }
                }.padding().frame(height: 70)
                Divider().padding(.leading).padding(.trailing)
                List {
                    LibraryCell()
                }
            }
            .navigationTitle("Library")
        }
        
    }
}

struct LibraryCell: View {
    var body: some View {
        HStack {
            Image("Image")
                .resizable()
                .cornerRadius(5)
                .frame(width: 80, height: 50)
            VStack {
                Text("Track")
                Text("Artist")
            }
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
