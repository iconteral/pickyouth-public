import React from 'react'
import ReactDOM from 'react-dom';
import {BroswerRouter as Router, Route, Link} from "react-router-dom";

import GrabTicket from './GrabTicket';
import MyTickets from './MyTicket';

class Entry extends React.Component {

    constructor(props) {
        super(props);
    }

    render() {
        return (
            <Router>
                <div className="entry">
                    <header>好想去看！！</header>

                    <Link to="/grab">
                        <button className="entry-button">我要抢票！</button>
                    </Link>
                    <Link to="/tickets">
                        <button className="entry-button">我抢到票没？</button>
                    </Link>

                    <Route path="/tickets" component={MyTickets} />
                    <Route path="/grab"  component={GrabTicket} />
            
                </div>
            </Router>
        );
    }

}

export default Entry;