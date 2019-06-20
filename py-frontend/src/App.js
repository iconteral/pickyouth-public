import React from 'react';
import {BroswerRouter as Router, Route, Link} from "react-router-dom"

import './App.css';
import Entry from './entry'
import GrabTicket from './GrabTicket'
import MyTickets from './MyTicket'

function App() {
  return (
    <div className="container">

      <Router>

          <header>好想去看！！</header>

          <Link to="/grab">
            <button className="entry-button">我要抢票！</button>
          </Link>
          <Link to="/tickets">
            <button className="entry-button">我抢到票没？</button>
          </Link>
          

          <Route path="/" exact component={Entry} />
          <Route path="/tickets" component={MyTickets} />
          <Route path="/grab"  component={GrabTicket} />
        
      </Router>

      <footer className="footer">
        <p>第三届青年夏日盛典暨毕业献礼 x 请回答9102</p>
      </footer>
    </div>
  );
}

export default App;
