# Reboxed                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                             
A modern SwiftUI app for iOS, iPadOS and macOS that helps you catalogue and track your belongings during a move or relocation.                                                                                                                                 
 
## Features                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                             
- **Hierarchy**: Place → Room (optional) → Box → Item                                                                                                                                                                                                          
- **QR codes**: Every place, room, box and item gets a unique typed ID (P-, R-, B-, I-). Print labels and scan them with the camera to jump directly to any entry.
- **Multi-scan**: Sweep the camera over several boxes at once and get an instant inventory list.                                                                                                                                                               
- **Item linking**: Link related objects — scan a chair and see which box holds its screws.                                                                                                                                                                    
- **Relocation mode**: Set a destination for any box or item. When you scan it at the new location, the app detects the move and offers to update it automatically.                                                                                            
- **Customisable lists**: Box types, owners and other fields use user-maintained lists with sensible defaults.                                                                                                                                                 
- **iCloud sync**: All data syncs privately via CloudKit across your devices.                                                                                                                                                                                  
- **Label printing**: Generate PDF label sheets — 2, 4, 6, 8, 12 or 16 per A4 page.                                                                                                                                                                            
                                                                                                                                                                                                                                                               
## Requirements                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                               
- iOS 17+ / iPadOS 17+ / macOS 14+                                                                                                                                                                                                                             
- An Apple Developer account with iCloud (CloudKit) enabled
                                                                                                                                                                                                                                                               
## Setup                                                                                                                                                                                                                                                     

1. Clone the repo and open `Reboxed.xcodeproj`.                                                                                                                                                                                                                
2. In *Signing & Capabilities*, set your team and confirm the CloudKit container is `iCloud.me.grossen.Reboxed`.
3. Build and run.                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                             
## Status                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                             
🚧 Work in progress.

## License                                                                                                                                                                                                                                                     
 
MIT       
