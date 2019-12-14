(() => {
    class myWebsocketHandler {
      setupSocket() {
          // set up a websocket
        this.socket = new WebSocket("ws://localhost:4000/ws/chat")
  
        // add message listeners - on event, add our ptag document 
        this.socket.addEventListener("message", (event) => {
          const pTag = document.createElement("p")
          pTag.innerHTML = event.data
  
          document.getElementById("main").append(pTag)
        })
  
        // on close, do "setupSocket"?????
        this.socket.addEventListener("close", () => {
          this.setupSocket()
        })
      }
  
      // on submit, we prevent the natural behavior of it, 
      // get the message element, put our input into it, and send it thru the socket 
      submit(event) {
        event.preventDefault()
        const input = document.getElementById("message")
        const message = input.value
        input.value = ""
  
        // send the message in the json data
        this.socket.send(
          JSON.stringify({
            data: { message: message },
          })
        )
      }
    }
  
    const websocketClass = new myWebsocketHandler()
    websocketClass.setupSocket()
    
    // add a click listener to the button for submission
    document.getElementById("button")
      .addEventListener("click", (event) => websocketClass.submit(event))
  })()