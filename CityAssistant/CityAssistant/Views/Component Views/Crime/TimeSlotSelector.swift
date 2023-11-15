//
//  CrimeControls.swift
//  CityAssistant
//
//  Created by Jules Maslak on 9/24/23.
//

import Foundation
import SwiftUI

struct TimeSlotSelector: View {
    var sliderChangedAction: ((Int) -> Void)?
    let timeSlots: [TimeSlotGrouping]
    @State var selectedGroup: TimeSlotGrouping
    @State var selectedTime: Double

    init(timeSlots: [TimeSlotGrouping], sliderChangedAction: ((Int) -> Void)?) {
        self.selectedGroup = timeSlots.first! //this array should never be empty
        self.timeSlots = timeSlots
        self.sliderChangedAction = sliderChangedAction
        self.selectedTime = 1
    }
    
    var body: some View {
        VStack (alignment: .trailing)
        {
            Spacer()
            
            HStack (alignment: .center) {
                
                Picker("Select a day", selection: $selectedGroup)
                {
                    ForEach(timeSlots, id: \.id)
                    {
                        Text($0.Key)
                    }
                }
                
                //we could adjust the available times to be dynamic but I don't think it makes sense bc it probably wont ever change
                Slider(value: $selectedTime, in: 1...4, onEditingChanged: SliderValueChanged)
            }.background(RoundedRectangle(cornerRadius: 10.0))
        }
    }
    
    func SliderValueChanged(_ : Bool)
    {
        let selectedTimeSlotId = selectedGroup.TimeSlots.first(where: {$0.TimeOfDay == Int(selectedTime)})?.Id ?? 0
        sliderChangedAction!(selectedTimeSlotId)
    }
}

struct TimeSlotSelector_Previews: PreviewProvider {
    static var previews: some View {
        let timeSlots = [
            TimeSlotGrouping(Key: "Sunday", TimeSlots: [
                TimeSlot(dayOfWeek: "Sunday", timeOfDay: 1, id: 1),
                TimeSlot(dayOfWeek: "Sunday", timeOfDay: 2, id: 2),
                TimeSlot(dayOfWeek: "Sunday", timeOfDay: 3, id: 3),
                TimeSlot(dayOfWeek: "Sunday", timeOfDay: 4, id: 4)
            ]),
            TimeSlotGrouping(Key: "Monday", TimeSlots: [
                TimeSlot(dayOfWeek: "Monday", timeOfDay: 1, id: 5),
                TimeSlot(dayOfWeek: "Monday", timeOfDay: 2, id: 6),
                TimeSlot(dayOfWeek: "Monday", timeOfDay: 3, id: 7),
                TimeSlot(dayOfWeek: "Monday", timeOfDay: 4, id: 8)
            ]),
        ]
        
        
        TimeSlotSelector(timeSlots: timeSlots, sliderChangedAction: nil)
    }
}
