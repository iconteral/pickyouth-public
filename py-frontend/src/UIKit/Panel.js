import React from 'react';

class Panel extends React.Component {

    render() {
        return (
            <div className="panel">
                {this.props.title && <div className="panel-title">
                    {this.props.title}
                </div>}
                {this.props.children}
            </div>
        );
    }
    
}

class PanelItem extends React.Component {

    render() {
        return (
            <div className="panel-item">
                {this.props.children}
            </div>
        );
    }
    
}

export default {Panel, PanelItem};