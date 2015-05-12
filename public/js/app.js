$(function() {
    var page = window.location.pathname;
    var link = $("#home-link")
    if (page === "/signup.erb") {
        link.html("<a href='/landing.erb'>Home</a>")
    }
    else if (page === "/landing.erb" || page === '/user/signout') {
        link.html("<a href='/signup.erb'>Sign Up!</a>")
    }
    else {
        link.html("<a href='/topics.erb'>Topics</a>")
    }
});

$(function() {
    var page = window.location.pathname;
    var link = $("#users-link");
    if (page === '/landing.erb' || page === '/signup.erb' || page === '/user/signout') {
        link.css("visibility","hidden")
    }
});