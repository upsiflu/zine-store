

/**
 * syncs a firebase user
 **/
export class RemoteUser extends HTMLElement { 
    // Attributes come from Elm
    static get observedAttributes() { return ['command', 'recent-note']; }



    connectedCallback () {
        console.log ("connectedCallback");
      // here goes the code you want to run when your custom element is rendered and initialised
    }
  
    disconnectedCallback () {
        console.log ("disconnectedCallback");
      // here goes the actions you should do when it's time to destroy/remove your custom element
    }

    attributeChangedCallback (name, oldValue, newValue) {
        console.log (name, oldValue, newValue);
    }
  
    
  }
  
  // the last important step here: registering our element so people can actually use it in their HTML
  customElements.define('remote-user', RemoteUser);
  
  