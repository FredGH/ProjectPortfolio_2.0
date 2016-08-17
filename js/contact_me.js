/** @jsx React.DOM */


var ContactMe = React.createClass({
  render: function() {
    return (
        <div className="container">
            <div className="row">
                <div className="col-lg-12 text-center">
                    <h2>Contact Me</h2>
                    <hr className="star-primary" />
                </div>
            </div>
            <div className="row">
                <div className="col-lg-8 col-lg-offset-2">
				  <div className="bootstrap-iso">
				    <div className="container-fluid">
				      <div className="row">
				        <div className="col-md-6 col-sm-6 col-xs-12">
                          <form action="https://formden.com/post/2Zvlj6AV/" method="post">
                            <div className="form-group ">
                              <label className="control-label " for="name"> Name </label>
                              <input className="form-control" id="name" name="name" type="text"/>
                            </div>
                            <div className="form-group ">
                              <label className="control-label requiredField" for="email"> Email <span className="asteriskField"> * </span> </label>
                              <input className="form-control" id="email" name="email" type="text"/>
                            </div>
                            <div className="form-group ">
                              <label className="control-label " for="subject"> Subject </label>
                              <input className="form-control" id="subject" name="subject" type="text"/>
                            </div>
                            <div className="form-group ">
                              <label className="control-label " for="message"> Message </label>
                              <textarea className="form-control" cols="40" id="message" name="message" rows="10"></textarea>
                            </div>
                            <div className="form-group">
                              <div>

                                <button className="btn btn-custom " name="submit" type="submit"> Submit </button>
                              </div>
                            </div>
                          </form>
                        </div>
                      </div>
				    </div>
				  </div>
                </div>
             </div>
        </div>
    );
  }
});

React.render(
  <ContactMe  />,
  document.getElementById('contact-me')

);


