//
//  AnimatedBezier.mm
//
//  Created by Zhang Yungui on 14-7-6.
//  Copyright (c) 2014, https://github.com/touchvg/vgplay-ios
//

#import "GiPlayingHelper.h"
#import "GiPlayProvider.h"
#import "GiViewHelper.h"
#include "mgshapes.h"
#include "mgpathsp.h"
#include "mgshapet.h"

static Point2d d2m(float x, float y, GiViewHelper *helper)
{
    CGPoint pt = [helper displayToModel:CGPointMake(x, y)];
    return Point2d(pt.x, pt.y);
}

void addAnimatedBezierDemo(GiPlayingHelper *play)
{
    __block Point2d pt1, pt2, pt3, pt4;
    __block float t = 0;
    
    [play addPlayProvider:^int(GiFrame frame) {
        MgShapes *shapes = MgShapes::fromHandle(frame.shapes);
        
        if (shapes->getShapeCount() == 0) {
            GiViewHelper *helper = [GiViewHelper sharedInstance:frame.view];
            MgShapeT<MgPathShape> path;
            
            path._context.setLineWidth(-5, true);
            pt1 = d2m(10, 50, helper);
            pt2 = d2m(100, 400, helper);
            pt3 = d2m(300, 400, helper);
            pt4 = d2m(300, 50, helper);
            
            path._shape.path().moveTo(pt1);
            path._shape.path().bezierTo(pt2, pt3, pt4);
            shapes->addShape(path);
        }
        
        if (frame.tick < frame.lastTick + 10) {
            return 0;
        }
        
        MgShape* newsp = shapes->getLastShape()->cloneShape();
        GiPath& path = ((MgPathShape*)newsp->shape())->path();
        
        Point2d pts[12] = { pt1, pt2, pt3, pt4 };
        mgcurv::splitBezier(pts, t, pts + 4, pts + 8);
        path.clear();
        path.moveTo(pts[4]);
        path.beziersTo(3, pts + 5);
        
        t += 1e-2;
        if (t > 1)
            t = 0;
        shapes->updateShape(newsp, true);
        return 1;
    } ended:nil tag:1];
}