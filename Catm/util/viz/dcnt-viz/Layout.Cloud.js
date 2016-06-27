/*!
Copyright (c) 2011, Nick Rabinowitz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/**
 * @class Abstract class for "cloud" visualizations - roughly circular clouds of
 * non-overlapping nodes.
 * @extends pv.Layout
 */
pv.Layout.Cloud = function() {
    pv.Layout.call(this);
    var that = this,
        notImplemented = function() {
            throw new Exception("Not implemented")
        };
    
    // the node prototype
    (this.node = new pv.Mark()
        .data(function() { return that.nodes(); })
        .top(function(d) { return d.y; })
        .left(function(d) { return d.x; })
    ).parent = this;
    
    // set placeholder methods
    this.$setSize = this.$collide = this.$getBox = notImplemented;
};

pv.Layout.Cloud.prototype = pv.extend(pv.Layout)
    .property("nodes", function(v) {
        return v.map(function(d, i) {
            if (typeof d != "object") d = {nodeValue: d};
            return d;
        });
    })
    .property("padding", Number)
    .property("spiralTightness", Number)
    .property("spiralDistance", Number)
    .property("gridRows", Number)
    .property("gridCols", Number)
    .property("verticalSkew", Number)
    .property("horizontalSkew", Number);
    
pv.Layout.Cloud.prototype.defaults = new pv.Layout.Cloud()
    .extend(pv.Layout.prototype.defaults)
    .nodes([])
    .padding(2)
    .spiralTightness(.1)
    .spiralDistance(2)
    .gridRows(16)
    .gridCols(16)
    .verticalSkew(0)
    .horizontalSkew(0);
    
pv.Layout.Cloud.prototype.buildImplied = function(s) {
    pv.Layout.prototype.buildImplied.call(this, s);
    var that = this,
        collide = that.$collide(s.padding),
        setSize = that.$setSize,
        getBox = that.$getBox,
        vskew = that.verticalSkew(),
        hskew = that.horizontalSkew(),
        nodes = s.nodes;
    
    var CollisionGrid = function(rows, cols) {
            var g = this,
                table = {},
                cw = s.width/cols,
                ch = s.height/rows,
                keys = function(n) {
                    var bb = getBox(n),
                        minx = Math.floor(bb.x1/cw),
                        maxx = Math.floor(bb.x2/cw),
                        miny = Math.floor(bb.y1/ch),
                        maxy = Math.floor(bb.y2/ch),
                        x, y, ks=[];
                    for (x=minx; x<=maxx; x++) {
                        for (y=miny; y<=maxy; y++) {
                            ks.push([x,y]);
                        }
                    }
                    return ks;
                };
            g.add = function(n) {
                keys(n).forEach(function(k) {
                    var sk = k[0]+','+k[1];
                    if (!(sk in table)) {
                        table[sk] = [];
                    }
                    table[sk].push(n);
                });
            };
            g.getPool = function(n) {
                return pv.blend(
                    keys(n).map(function(k) {
                        var sk = k[0]+','+k[1];
                        if (sk in table) return table[sk];
                    }).filter(pv.identity)
                );
            }
        },
        cg = new CollisionGrid(16,16),
        lastHit;
        
    function testCollision(n, d) {
        if (!d) lastHit = null;
        if (lastHit) {
            if (collide(n, lastHit)) return true;
            else lastHit = null;
        }
        // get possible hits
        var pool = cg.getPool(n),
            i;
        for (i=0; i<pool.length; i++) {
            if (collide(n, pool[i])) {
                lastHit = pool[i];
                return true;
            }
        }
        return false;
    }
    
    function placeNode(n, d) {
        var d = d || 0,
            b = n.size * s.spiralTightness,
            dist = n.size * s.spiralDistance,
            w = s.width,
            h = s.height,
            t,
            theta = function(d) {
                return d * Math.PI / Math.sqrt(Math.PI * Math.PI * b * d / dist);
            },
            x = function(d, hs) {
                return w/2 + hs + b * t * Math.cos(t);
            },
            y = function(d, vs) {
                return h/2 + vs + b * t * Math.sin(t);
            };
        if (d) {
            if ((vskew && !n.vs) || (hskew && !n.hs)) {
                // if skews are defined, initialize
                if (vskew) {
                    n.vs = pv.random(-1 * vskew/2, vskew/2);
                }
                if (hskew) {
                    n.hs = pv.random(-1 * hskew/2, hskew/2);
                }
            }
            // if skews are not defined, zero out
            if (n.vs === undefined) {
                n.vs = 0;
            }
            if (n.hs === undefined) {
                n.hs = 0;
            }
            
            t = theta(d);
            n.x = x(d, n.hs);
            n.y = y(d, n.vs);
        }
        return testCollision(n, d);
    }
    // size nodes
    nodes.forEach(setSize);
    // sort by size
    nodes.sort(function(a,b) { return pv.reverseOrder(a.size, b.size) });
    // place
    nodes.forEach(function(n) {
        var d = 0;
        while (placeNode(n, ++d)) {}
        cg.add(n);
    });
};


/**
 * @class Implements a cloud visualization with circle-shaped nodes (i.e. pv.Dot)
 * @extends pv.Layout.Cloud
 */
pv.Layout.Cloud.Circle = function() {
    pv.Layout.Cloud.call(this);
    var that = this;
    
    // add shapeSize to the node prototype
    this.node
        .size(function(d) { return d.size*d.size; });
    
    // default size function
    this.$size = function() { return 10; };
    
    // item size - Dot version
    this.$setSize = function(n) {
        n.size = Math.sqrt(that.$size(n));
    };
    
    // item collision detection - Dot version
    this.$collide = function(padding) {
        return function(n1, n2) {
            return n1 != n2 &&
                // distance between nodes
                Math.sqrt(Math.pow(n1.x-n2.x, 2) + Math.pow(n1.y-n2.y, 2)) < 
                    // sum of node radii and padding
                    (n1.size + n2.size + padding);
        }
    };
    
    // item bounding box - Dot version
    this.$getBox = function(n) {
        return {
            x1: n.x - n.size,
            y1: n.y - n.size,
            x2: n.x + n.size,
            y2: n.y + n.size
        };
    };
};
pv.Layout.Cloud.Circle.prototype = pv.extend(pv.Layout.Cloud);

pv.Layout.Cloud.Circle.prototype.size = function(f) {
    this.$size = pv.functor(f);
    return this;
};

    
/**
 * @class Implements a cloud visualization with box-shaped nodes (e.g. pv.Panel or pv.Bar)
 * @extends pv.Layout.Cloud
 */
pv.Layout.Cloud.Box = function() {
    pv.Layout.Cloud.call(this);
    var that = this;
    
    // update the node prototype
    this.node
        .top(function(d) { return d.y - d.h/2; })
        .left(function(d) { return d.x - d.w/2; })
        .width(function(d) { return d.w; })
        .height(function(d) { return d.h; });
    
    // default size functions
    this.$nodeWidth = this.$nodeHeight = function() { return 10; };
    
    var count=0;
    // item size - box version
    this.$setSize = function(n) {
        var w = that.$nodeWidth(n),
            h = that.$nodeHeight(n);
        // we still need to set the size - used in layout
        n.size = Math.sqrt(w * h);
        if (that.alternate() && count++ % 2) {
            n.w = h;
            n.h = w;
            n.rotated = true;
        } else {
            n.w = w;
            n.h = h;
        }
    }
    
    // item collision detection - box version
    this.$collide = function(padding) {
        return function(n1, n2) {
            var nb1 = that.$getBox(n1),
                nb2 = that.$getBox(n2);
            return n1 != n2 &&
                ((((nb1.x1-padding) < nb2.x1 && nb2.x1 < (nb1.x2+padding)) || 
                    ((nb1.x1-padding) < nb2.x2 && nb2.x2 < (nb1.x2+padding)) ||
                    (nb2.x1 < nb1.x1 && nb2.x2 > nb1.x2)) &&
                (((nb1.y1-padding) < nb2.y1 && nb2.y1 < (nb1.y2+padding)) || 
                    ((nb1.y1-padding) < nb2.y2 && nb2.y2 < (nb1.y2+padding))) ||
                    (nb2.y1 < nb1.y1 && nb2.y2 > nb1.y2));
        }
    };
    
    // item bounding box - box version
    this.$getBox = function(n) {
        return {
            x1: n.x - n.w/2,
            y1: n.y - n.h/2,
            x2: n.x + n.w/2,
            y2: n.y + n.h/2
        };
    }
};
pv.Layout.Cloud.Box.prototype = pv.extend(pv.Layout.Cloud)
    .property("alternate", Boolean);

pv.Layout.Cloud.Box.prototype.nodeWidth = function(f) {
    this.$nodeWidth = pv.functor(f);
    return this;
};
pv.Layout.Cloud.Box.prototype.nodeHeight = function(f) {
    this.$nodeHeight = pv.functor(f);
    return this;
};
    
pv.Layout.Cloud.Box.prototype.defaults = new pv.Layout.Cloud.Box()
    .extend(pv.Layout.Cloud.prototype.defaults)
    .alternate(false);
    


/**
 * @class Implements a cloud visualization with Label nodes
 * @extends pv.Layout.Cloud.Box
 */
pv.Layout.Cloud.Text = function() {
    pv.Layout.Cloud.Box.call(this);
    var that = this;
    
    // add the label prototype
    (this.label = new pv.Mark()
        .extend(this.node)
        .top(function(n) { return n.y })
        .left(function(n) { return n.x })
        .font(function(n) { return that.$font(n); })
        .text(function(n) { return that.$text(n); })
        .textBaseline("middle")
        .textAlign("center")
        .textAngle(function(n) { return n.rotated ? Math.PI/-2 : 0; })
    ).parent = this;
    
    // default font and text
    this.$font = function() { return "bold 14px Arial"; };
    this.$text = function(n) { return n.nodeName || n.nodeValue; };
    
    // remove the default fill from the node
    this.node
        .fillStyle(null);
    var setBoxSize = that.$setSize;
    this.$setSize = function(n) {
        var id = 'pv-text-width-tester',
            $tag = $('#' + id);
        if (!$tag.length) {
            $tag = $('<span id="' + id + '" style="display:none;font:' + that.$font(n) + ';">' + that.$text(n) + '</span>');
            $('body').append($tag);
        } else {
            $tag.css({font:that.$font(n)}).html(that.$text(n));
        }
        that.$nodeWidth = pv.functor($tag.width());
        that.$nodeHeight = pv.functor($tag.height() *.9);
        setBoxSize(n);
    };
    
    // ditch some things we don't need
    delete this.nodeWidth;
    delete this.nodeHeight;
};
pv.Layout.Cloud.Text.prototype = pv.extend(pv.Layout.Cloud.Box);
    
pv.Layout.Cloud.Text.prototype.font = function(f) {
    this.$font = pv.functor(f);
    return this;
};
pv.Layout.Cloud.Text.prototype.text = function(f) {
    this.$text = pv.functor(f);
    return this;
};