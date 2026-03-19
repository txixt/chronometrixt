//
//  SwiftUIView.swift
//  chronometrixt
//
//  Created by Becket on 3/17/26.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "gear")
                Text("settings")
                Spacer()
                Button(action: { gov.sheet = .none } ) {
                    Image(systemName: "plus")
                        .rotationEffect(Angle(degrees: 45))
                        .shadow(color: .gray, radius: 3)
                }
            }
            .font(.largeTitle.bold())
            .foregroundColor(.primary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 2.5).frame(width: 100, height: 5)
                Divider()
            }
            
            VStack {
                ZStack {
                    Divider()
                    HStack {
                        Image(systemName: "info.circle")
                        Text("metrixt tutorial")
                        Spacer()
                        Image(systemName: "play.fill")
                            .font(.title2)
                            .shadow(color: .gray, radius: 3)
                    }
                }
                .padding(.vertical)
                
                ZStack {
                    Divider()
                    HStack {
                        Image(systemName: "calendar.badge")
                        Text("sync with iphone calendar")
                        Image(systemName: "questionmark.circle")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                            .font(.title2)
                            .shadow(color: .gray, radius: 3)
                    }
                }
                .padding(.bottom)
                
                ZStack {
                    Divider()
                    HStack {
                        ZStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Image(systemName: "arrow.forward")
                                .offset(x: -8)
                        }
                        .offset(x: 8)
                        .padding(.trailing, 7)
                        Text("import calendar")
                        Image(systemName: "questionmark.circle")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "iphone.and.arrow.right.inward")
                            .font(.title2)
                            .shadow(color: .gray, radius: 3)
                    }
                }
                .padding(.bottom)
                
                ZStack {
                    Divider()
                    HStack {
                        ZStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Image(systemName: "arrow.forward")
                                .offset(x: 8)
                        }
                        .padding(.trailing, 7)
                        Text("export calendar")
                        Image(systemName: "questionmark.circle")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "iphone.and.arrow.right.outward")
                            .font(.title2)
                            .shadow(color: .gray, radius: 3)
                    }
                }
                .padding(.bottom)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 1.5).frame(width: 100, height: 3)
                        .foregroundColor(.gray)
                    Divider()
                }
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    ZStack {
                        Divider()
                        HStack {
                            Image(systemName: "ellipsis.curlybraces")
                            Text("more from us")
                            Spacer()
                            Text("+×ı×+")
                                .font(.title3)
                                .shadow(color: .gray, radius: 3)
                        }
                    }
                    Text("And contact link for feedback.")
                        .font(.caption2)
                        .bold(false)
                        .padding(.bottom)
                    
                    ZStack {
                        Divider()
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("privacy policy")
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.title3)
                                .shadow(color: .gray, radius: 3)
                        }
                    }
                    Text("We do not collect any user data.")
                        .font(.caption2)
                        .bold(false)
                        .padding(.bottom)
                    
                    ZStack {
                        Divider()
                        HStack {
                            HStack(spacing: 0) {
                                Image(systemName: "hand.point.right")
                                Image(systemName: "hand.point.left")
                            }
                            Text("rate us in the app store")
                            Spacer()
                            Image(systemName: "checkmark.seal")
                                .font(.title3)
                                .shadow(color: .gray, radius: 3)
                        }
                    }
                    Text("If you love us?")
                        .font(.caption2)
                        .bold(false)
                }
                .foregroundStyle(.gray)


            }
            .bold()
            .foregroundColor(.primary)
            
            Spacer ()
            
            HStack {
                Spacer()
                Text("mit license \(gov.eternalNow.time.yearTxt) +×ı×+")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .font(.subheadline)
        .padding()
        .monospaced()
    }
}

#Preview {
    SettingsView(gov: Governor())
}
