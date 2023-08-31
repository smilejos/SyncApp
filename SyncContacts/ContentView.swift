//
//  ContentView.swift
//  SyncContacts
//
//  Created by Jos Tung on 2023/8/9.
//
import SwiftUI
import Contacts

struct ContentView: View {
    @State private var contacts: [CNContact] = []
    
    var body: some View {
        VStack {
            Text("Contacts")
                .font(.title)
                .padding()
            
            
            Button(action: {
                            addSampleContact()
                        }) {
                            Text("Add Sample Contact")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
            
            List(contacts, id: \.self) { contact in
                VStack(alignment: .leading) {
                    Text("\(contact.givenName) \(contact.familyName)")
                    ForEach(contact.emailAddresses, id: \.self) { email in
                        Text(email.value as String)
                    }
                }
            }
        }
        .onAppear(perform: requestContactsAuthorization)
    }
    
    func requestContactsAuthorization() {
        let contactStore = CNContactStore()

        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            fetchContacts()
        case .denied, .restricted:
            print("Access to contacts is denied or restricted.")
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { [self] granted, error in
                if granted {
                    self.fetchContacts()
                } else if let error = error {
                    print("Error requesting contacts authorization: \(error.localizedDescription)")
                }
            }
        @unknown default:
            print("Unknown authorization status.")
        }
    }

    
    func fetchContacts() {
        let contactStore = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            try contactStore.enumerateContacts(with: request) { contact, stop in
                contacts.append(contact)
            }
        } catch {
            print("Error fetching contacts: \(error)")
        }
    }
    
    func addSampleContact() {
        let newContact = CNMutableContact()
        newContact.givenName = "Micron"
        newContact.familyName = "Org"
        let emailAddress = CNLabeledValue(label: CNLabelHome, value: "micron@micron.com" as NSString)
        newContact.emailAddresses = [emailAddress]

        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)

        let contactStore = CNContactStore()

        do {
            try contactStore.execute(saveRequest)
            print("Sample contact added successfully!")
            fetchContacts() // Refresh the list to show the new contact
        } catch {
            print("Error adding sample contact: \(error)")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
