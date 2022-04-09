# Getting started

## Usage

Call the function handlePitch and give it the pitch you want to evaluate. 

```dart
//Create a PitchHandler and choose the instrument type
final pitchUp = PitchHandler(InstrumentType.guitar);

//Uses the pitchUp library to check if a a given pitch consists of a guitar note and if it's tuned 
final handledPitchResult = pitchUp.handlePitch(pitch);
```

The handledPitchResult containing the result of calculation will return: 
  
  - note: The closest note to the pitch that was given. If any.
  - tuningStatus: 
    - tuned
    - toolow
    - toohigh
    - waytoolow
    - waytoohigh
    - undefined - The pitch is not close to a expected guitar note.
  - expectedFrequency: The expected frequency of the closest note.
  - diffFrequency: The difference of the frequency found in the analised pitch compared to the expected pitch of the closest note. 
  - diffCents: The interval difference in cents to the expected closest tuned note. 

