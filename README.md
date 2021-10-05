# RWTH Wall Calendar to ICS Converter

Uses the PDF version of the calendar, converts it into HTML using Python, uses Julia to match each event to a specific date using the Euclidian distance <img src="https://render.githubusercontent.com/render/math?math={\|\boldsymbol{x}\|}_2"> to the nearest number <img src="https://render.githubusercontent.com/render/math?math=i \in \{1,2,\dots,31\}"> while the numbers <img src="https://render.githubusercontent.com/render/math?math=i"> are then matched to their corresponding month using just the <img src="https://render.githubusercontent.com/render/math?math=x_2">-coordinate and finally uses Python again to create the `ICS` calendar.

## Tutorial

### 1. Pre
- Have Python 3 and Julia 1.6 installed
- Get calendar as PDF, from [here](https://www.rwth-aachen.de/cms/root/Die-RWTH/Einrichtungen/Verwaltung/Stabsstellen/~rdf/Marketing/), rename it to `calendar.pdf`

### 2. Convert PDF to HTML

```bash
pip install pdf-tools
pdf2html calendar.pdf > calendar.html
```

### 3. Get CSV of events

```bash
julia convert.jl
```

### 4. Use Python again to create ICS file

*Julia doesn't have ICS lib and Julia Conda doesn't find "ics" while "icalendar" doesn't work using `pycall` :-(*

```bash
pip install ics
python3 create-ics.py
```

### 5. Import ICS file 😎
