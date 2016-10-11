Input_Demo

This illustrates the use of `Input a` types for tracking validated input in Elm, as I write about [here](http://www.mechanicaldruid.com/update-to-input-tracking-in-elm/). 

I'd like to thank @jckdrpr from elm-slack for the tip about destructuring the model in the update function, even though I'm not using that anymore. 

Points that I want to highlight include:
* That we can display different inputs based on application state
* That we can use these inputs to build complex data structures
* The use of case statements and pattern matching to do overall validation based on multiple individual inputs (in the `AddPerson` branch of `update`, and in `shouldDisableButton`)


Things that would be good to add:
* CSS 
* A function `makePersonFromInput : InputBlock -> Maybe Person` that could be used in both the update and view code (the view code would check to make sure a valid person came out, and set the button disabled accordingly)