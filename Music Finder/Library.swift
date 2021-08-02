//
//  Library.swift
//  Music Finder
//
//  Created by Oleg Tsarenkoff on 25.07.21.
//

import SwiftUI
import URLImage

struct Library: View {
    
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var showAlert = false
    @State private var track: SearchViewModel.Cell!
    
    var tabBarDelegate: MainTabBarControllerDelegate?
    
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button(action: {
                            self.track = self.tracks[0]
                            self.tabBarDelegate?.maximiseTrackDetailController(viewModel: self.track)
                        }, label: {
                            Image(systemName: "play.fill")
                                .frame(width: geometry.size.width / 2 - 10,
                                       height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 1, green: 0.2156862745, blue: 0.3725490196, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9161354899, green: 0.9106894135, blue: 0.9203217626, alpha: 1)))
                                .cornerRadius(10)
                            
                        })
                        Button(action: {
                            self.tracks = UserDefaults.standard.savedTracks()
                        }, label: {
                            Image(systemName: "arrow.2.circlepath")
                                .frame(width: geometry.size.width / 2 - 10,
                                       height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 1, green: 0.2156862745, blue: 0.3725490196, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9161354899, green: 0.9106894135, blue: 0.9203217626, alpha: 1)))
                                .cornerRadius(10)
                        })
                    }
                }.padding().frame(height: 70)
                Divider().padding(.leading).padding(.trailing)
                List {
                    ForEach(tracks) { track in LibraryCell(cell: track).gesture(
                        LongPressGesture()
                            .onEnded { _ in
                                self.showAlert = true
                                self.track = track
                            }
                            .simultaneously(with:
                                                TapGesture()
                                                .onEnded{ _ in
                                                    self.track = track
                                                    self.tabBarDelegate?.maximiseTrackDetailController(viewModel: self.track)
                                                }))
                    }
                    .onDelete(perform: delete)
                }
            }.actionSheet(isPresented: $showAlert,
                          content: {
                            ActionSheet(title: Text("Delete \(track.artistName) - \(track.trackName)?"),
                                        buttons: [.destructive(Text("Delete"), action: {
                                            self.delete(track: self.track)
                                        }), .cancel()
                                        ])
                          })
            .navigationTitle("Library")
        }
    }
    
    func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
    func delete(track: SearchViewModel.Cell) {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return }
        tracks.remove(at: myIndex)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
}

struct LibraryCell: View {
    
    var cell: SearchViewModel.Cell
    
    var body: some View {
        HStack {
            URLImage(URL(string: cell.iconUrlString ?? "")!) { Image in
                Image
                    .resizable()
                    .cornerRadius(5)
                    .frame(width: 60, height: 60)
            }
            VStack(alignment: .leading) {
                Text("\(cell.trackName)")
                Text("\(cell.artistName)")
            }
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
