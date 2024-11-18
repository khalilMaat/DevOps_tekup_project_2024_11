import React, { Component } from 'react';


export default class Nav extends Component {
  render() {
    return (
      <nav>
          <div className="nav-wrapper">
            <a href="/" className="brand-logo">Logo</a>
            <ul id="nav-mobile" className="right hide-on-med-and-down">
              <li><a href="/">HOME</a></li>
              <li><a href="">FACEBOOK</a></li>
              <li><a href="">LINKED IN</a></li>
            </ul>
          </div>
        </nav>
    );
  }
}
