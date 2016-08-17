/** @jsx React.DOM */

var AboutContent = React.createClass({
  render: function() {
    return (
        <div className="container">
          <div className="row">
            <div className="col-lg-12 text-center">
              <h2>About</h2>
                <hr className="star-light" />
            </div>
          </div>
        <div className="row">
          <div className="col-lg-4 col-lg-offset-2">
            <p>This web site 3 is dedicated to project I have been working on recently in the Data Sciences and Web technologies sapce.</p>
          </div>
          <div className="col-lg-4 col-lg-offset-2">
            <p>Please do not hesitate to contact me should you require more information on any of my projects.</p>
          </div>
        </div>
      </div>
    );
  }
});


React.render(
  <AboutContent />,
  document.getElementById('about-content')
);

