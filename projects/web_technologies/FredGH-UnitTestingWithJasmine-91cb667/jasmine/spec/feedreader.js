/* feedreader.js
 *
 * This is the spec file that Jasmine will read and contains
 * all of the tests that will be run against your application.
 */

/* We're placing all of our tests within the $() function,
 * since some of these tests may require DOM elements. We want
 * to ensure they don't run until the DOM is ready.
 */
$(function() {
    /* This is our first test suite - a test suite just contains
    * a related set of tests. This suite is all about the RSS
    * feeds definitions, the allFeeds variable in our application.
    */
    describe('RSS Feeds', function() {
        /* This is our first test - it tests to make sure that the
         * allFeeds variable has been defined and that it is not
         * empty. Experiment with this before you get started on
         * the rest of this project. What happens when you change
         * allFeeds in app.js to be an empty array and refresh the
         * page?
         */
        it('are defined', function() {
            expect(allFeeds).toBeDefined();
            expect(allFeeds.length).not.toBe(0);
        });

        /* Loops through each feed
         * in the allFeeds object and ensures it has a URL defined
         * and that the URL is not empty.
         */
        it('ensures it has a URL defined adds and that the URL is not empty', function () {
            for (var i =0; i <allFeeds.length; i++) {
                var feed = allFeeds[i];
                expect(feed.url).toBeDefined();
                expect(feed.url).not.toBe("");
                expect(feed.url).not.toEqual(jasmine.anything);
                expect(feed.url).toContain("http:");
                }
        });

        /* Loops through each feed
         * in the allFeeds object and ensures it has a name defined
         * and that the name is not empty.
         */
        it('ensures it has a name defined adds and that the name is not empty', function () {
            for (var i =0; i <allFeeds.length; i++) {
                var feed = allFeeds[i];
                expect(feed.name).toBeDefined();
                expect(feed.name).not.toBe("");
                expect(feed.name).not.toEqual(jasmine.anything);
            }
        });
    });

    /* "The menu" */
    describe('The menu', function() {

        /* Ensures the menu element is
         * hidden by default. You'll have to analyze the HTML and
         * the CSS to determine how we're performing the
         * hiding/showing of the menu element.
         */
        it('ensures the menu element is hidden by default', function () {
                expect($('body').hasClass('menu-hidden')).toBe(true);
        });

         /* Ensures the menu changes
          * visibility when the menu icon is clicked. This test
          * should have two expectations: does the menu display when
          * clicked and does it hide when clicked again.
          */
        it('ensures the menu changes visibility when the menu icon is clicked', function () {
            var menuIconLink = $('.menu-icon-link');
            var body = $('body');

            //initial state  => menu is hidden
            expect(body.hasClass('menu-hidden')).toBeTruthy();

            //after the first click => menu is not hidden
            menuIconLink.trigger('click');
            expect(body.hasClass('menu-hidden')).toBeFalsy();

            //after the second click => menu is  hidden
            menuIconLink.trigger('click');
            expect(body.hasClass('menu-hidden')).toBeTruthy();
        });
    });

    /* Initial Entries */
    describe('Initial Entries', function() {

        /* Ensures when the loadFeed
         * function is called and completes its work, there is at least
         * a single .entry element within the .feed container.
         * 'loadFeed()' is asynchronous so this test requires
         * the use of Jasmine's beforeEach and asynchronous done() function.
         */
        // Prior to running the expectation function run, load async the 'loadFeed'
        beforeEach(function (done){
            loadFeed(0, done);
        });
        // Ensures there is at least one entry
        it('after feed loads, it should have at least one entry', function (done) {
            expect($('.feed .entry').length).toBeGreaterThan(0);
            done();
        });
    });

    /* New Feed Selection */
    describe('New Feed Selection', function() {

        /* Ensures when a new feed is loaded
         * by the loadFeed function that the content actually changes.
         */
         var initContent, nextContent;
        beforeEach(function (done) {
            //get the original content
            initContent = $('.feed').find('.entry');
            //loads the first feed async
            loadFeed(1, done);
        });
        it('content should change', function (done) {
            nextContent = $('.feed').find('.entry');
            //check the content is changed
            expect(initContent).not.toBe(nextContent);
            done();
        });
    });

    /* A test suite for testing that it actually gets new content */
    describe('New Feed Selection' , function() {

        /* A test that ensures when a new feed is loaded by the loadFeed
         * function that the content actually changes.
         */
        var oldHref;
        var newHref;
        var index = 1;

        /* Load both feeds*/
        beforeEach(function(done) {
            loadFeed(index - 1, function() {
                oldHref = $('.entry-link').attr("href");
            });
            loadFeed(index, function() {
                newHref = $('.entry-link').attr("href");
                done();
            });
        });

        /* The index increases by one after the load of each test*/
        afterEach(function(done) {
            index++;
            done();
        });

        function newFeeds() {
            it('index [' + (i-1) + '] and [' + i + '] are not equal', function(done) {
                expect(oldHref).not.toBe(newHref);
                done();
            });

        }
        for(var i = 1; i < allFeeds.length; i++) {
            newFeeds();
        }
    });

}());