//
//  BookRepository.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//
import SwiftUI

class BookRepository: ObservableObject {
    @Published var books: [Book] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        books = [
            Book(
                title: "Harry Potter and the Philosopher’s Stone",
                author: "J. K. Rowling",
                coverImageUrl: "https://media.harrypotterfanzone.com/sorcerers-stone-us-childrens-edition-2013-1050x0-c-default.jpg",
                chapters: [
                    Chapter(
                        title: "The Boy Who Lived",
                        summary: "On an ordinary street in Surrey, Vernon Dursley notices strange occurrences—owls flying during the day, people in cloaks celebrating, and whispers about someone named Harry Potter. That night, Dumbledore and Professor McGonagall meet outside the Dursleys’ home, discussing the downfall of Voldemort, the dark wizard who killed Harry’s parents but mysteriously vanished after failing to kill baby Harry. Hagrid arrives on a flying motorbike, delivering the orphaned Harry to the Dursleys, his only remaining family. Dumbledore leaves a letter explaining everything, and they leave the sleeping baby with his lightning-shaped scar on the doorstep, marking the beginning of Harry’s extraordinary life.",
                        audioFileName: "book1chapter1.m4a"
                    ),
                    Chapter(
                        title: "The Vanishing Glass",
                        summary: "Ten years later, Harry lives a miserable life with the Dursleys, who force him to sleep in a cupboard under the stairs and treat him as an outcast. Dudley, his spoiled cousin, bullies Harry constantly, while Vernon and Petunia ensure Harry knows nothing about his true heritage. On Dudley’s birthday, the family visits the zoo, where Harry experiences a magical moment—he converses with a boa constrictor and accidentally makes the glass of its enclosure vanish, setting the snake free. The incident shocks the Dursleys, who punish Harry, though he remains bewildered by the mysterious things that occasionally happen around him.",
                        audioFileName: "book1chapter2.m4a"
                    ),
                    Chapter(
                        title: "The Letters from No One",
                        summary: "Harry begins receiving peculiar letters addressed specifically to him, written in emerald-green ink, but Vernon intercepts them before Harry can read them. Despite the Dursleys’ efforts to destroy or block the letters, they continue to arrive in increasing numbers and increasingly creative ways. In a desperate attempt to escape the letters, Vernon drives the family to a desolate hut on a rock in the sea during a storm. At midnight, on Harry’s eleventh birthday, a loud knock sounds at the door, heralding the arrival of someone unexpected.",
                        audioFileName: "book1chapter3.m4a"
                    )
                ]
            ),
            Book(
                title: "Harry Potter and the Chamber of Secrets",
                author: "J. K. Rowling",
                coverImageUrl: "https://media.harrypotterfanzone.com/chamber-of-secrets-us-childrens-edition-2013-1050x0-c-default.jpg",
                chapters: [
                    Chapter(
                        title: "The Worst Birthday",
                        summary: "Harry spends a lonely summer at the Dursleys’ house, ignored by his relatives and receiving no contact from his Hogwarts friends. As the Dursleys prepare for a dinner with a potential client, Harry is ordered to stay out of sight. Despite being back in the Muggle world, Harry misses Hogwarts deeply, feeling abandoned by Ron and Hermione. His frustration and isolation grow, especially on his twelfth birthday, which everyone around him ignores.",
                        audioFileName: "book2chapter1.m4a"
                    ),
                    Chapter(
                        title: "Dobby’s Warning",
                        summary: "While in his room, Harry meets Dobby, a nervous house-elf who warns him not to return to Hogwarts because terrible things will happen. Dobby admits to intercepting Harry’s friends’ letters all summer to make him feel forgotten. When Harry refuses to stay away from school, Dobby uses magic to ruin the Dursleys’ dinner party, causing the family to punish Harry by locking him in his room. Harry remains trapped until Ron and his brothers rescue him with their father’s flying car.",
                        audioFileName: "book2chapter2.m4a"
                    ),
                    Chapter(
                        title: "The Burrow",
                        summary: "Harry experiences life at the Burrow, the warm and magical home of the Weasley family. He’s amazed by the enchanted household items and enjoys Mrs. Weasley’s motherly care, something he’s never known. The Weasley family becomes Harry’s surrogate family, and he feels comforted and accepted. During breakfast, Harry and Ron receive letters from Hogwarts delivered by Errol, the exhausted Weasley owl.",
                        audioFileName: "book2chapter3.m4a"
                    )
                ]
            )
        ]
    }
}
