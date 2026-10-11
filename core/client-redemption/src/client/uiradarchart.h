/*
 * Copyright (c) 2010-2026 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma once

#include <framework/ui/uiwidget.h>

// A radar (spider) chart: a regular polygon grid with one spoke per axis, the first axis pointing
// up and the rest clockwise, and layers of values from 0 (centre) to 1 (outer ring) drawn on top
// in the order they were added.
class UIRadarChart final : public UIWidget
{
public:
    UIRadarChart() = default;

    void drawSelf(DrawPoolType drawPane) override;

    void setAxisCount(int count);
    int getAxisCount() const { return m_axisCount; }
    void setRingCount(const int count) { m_ringCount = std::max<int>(1, count); }
    void setGridColor(const Color& color) { m_gridColor = color; }
    void setGridWidth(const int width) { m_gridWidth = std::max<int>(1, width); }

    void clearLayers() { m_layers.clear(); }
    size_t addLayer(const Color& fillColor, const Color& lineColor, int lineWidth);
    void setLayerValues(size_t index, const std::vector<float>& values);
    void setLayerVisible(size_t index, bool visible);
    size_t getLayerCount() const { return m_layers.size(); }

    // where the given axis meets the outer ring, relative to the widget (for placing labels)
    Point getAxisPoint(int axis, float value);

protected:
    void onStyleApply(std::string_view styleName, const OTMLNodePtr& styleNode) override;

private:
    struct Layer
    {
        std::vector<float> values;
        Color fillColor;
        Color lineColor;
        int lineWidth;
        bool visible;
    };

    PointF getVertex(const PointF& center, float radius, int axis, float value) const;
    void drawLine(const PointF& a, const PointF& b, int width, const Color& color) const;

    std::vector<Layer> m_layers;
    Color m_gridColor{ 255, 255, 255, 60 };
    int m_axisCount{ 6 };
    int m_ringCount{ 5 };
    int m_gridWidth{ 1 };
};
