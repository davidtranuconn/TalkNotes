//
//  NoteCreateChangeViewController.swift
//  TalkNotes
//
//  Created by David Tran on 2020. 03. 21..
//  Copyright © 2020. David Tran. All rights reserved.
//

import UIKit

class NoteChangeViewController : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDoneButton: UIButton!
    @IBOutlet weak var noteDateLabel: UILabel!
    
    private let noteCreationTimeStamp : Int64 = Date().toSeconds()
    private(set) var changingNote : SimpleNote?

    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
        if self.changingNote != nil {
            noteDoneButton.isEnabled = true
        } else {
            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton, forEvent event: UIEvent) {
        if self.changingNote != nil {
            changeItem()
        } else {
            addItem()
        }
    }
    
    func setChangingNote(changingNote : SimpleNote) {
        self.changingNote = changingNote
    }
    
    private func addItem() -> Void {
        let note = SimpleNote(
            noteTitle:     noteTitleTextField.text!,
            noteText:      noteTextTextView.text,
            noteTimeStamp: noteCreationTimeStamp)

        NoteStorage.storage.addNote(noteToBeAdded: note)
        
        performSegue(
            withIdentifier: "backToMasterView",
            sender: self)
    }

    private func changeItem() -> Void {
        // get changed note instance
        if let changingNote = self.changingNote {
            // change the note through note storage
            NoteStorage.storage.changeNote(
                noteToBeChanged: SimpleNote(
                    noteId:        changingNote.noteId,
                    noteTitle:     noteTitleTextField.text!,
                    noteText:      noteTextTextView.text,
                    noteTimeStamp: noteCreationTimeStamp)
            )
            // navigate back to list of notes
            performSegue(
                withIdentifier: "backToMasterView",
                sender: self)
        } else {
            let alert = UIAlertController(
                title: "Unexpected error",
                message: "Cannot change the note, unexpected error occurred. Try again later.",
                preferredStyle: .alert)
            
            // add OK action
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default ) { (_) in self.performSegue(
                                              withIdentifier: "backToMasterView",
                                              sender: self)})
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set text view delegate so that we can react on text change
        noteTextTextView.delegate = self
        
        // check if we are in create mode or in change mode
        if let changingNote = self.changingNote {
            noteDateLabel.text = NoteDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
            noteTextTextView.text = changingNote.noteText
            noteTitleTextField.text = changingNote.noteTitle
            noteDoneButton.isEnabled = true
        } else {
            noteDateLabel.text = NoteDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
        }
        
        // For back button in navigation bar, change text
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }

    //Handle the text changes here
    func textViewDidChange(_ textView: UITextView) {
        if self.changingNote != nil {
            //change
            noteDoneButton.isEnabled = true
        } else {
            //create
            if ( noteTitleTextField.text?.isEmpty ?? true ) || ( textView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }

}
