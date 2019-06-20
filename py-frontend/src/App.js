import React from 'react';
import {BroswerRouter as Router, Route, Link} from "react-router-dom";

import './App.css';
import Entry from './entry';


function App() {
  return (
    <div className="container">

      <Router>

          <Route path="/" exact component={Entry} />
          
      </Router>

      <footer className="footer">
        <p>第三届青年夏日盛典暨毕业献礼 x 请回答9102</p>
      </footer>
    </div>
  );
}

export default App;
