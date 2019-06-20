import React from 'react';
import ReactDOM from 'react-dom';

import {Panel, PanelItem} from './UIKit/Panel';

class GrabTicket extends React.Component {
    constructor(props) {
        super(props);
    
        this.state = {
             
        }
    }

    render() {
        return (
            <Panel title="fuck">
                <PanelItem>
                    <h1>fuck</h1>
                </PanelItem>
            </Panel>
        );
    }
    
}

export default GrabTicket;