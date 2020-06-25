def dv_fun(params):
	a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p = params;
	DV = [
	a-i,	a-e,	m-e,	p-a,	n-d,	m-o,	a-k,	j-h,	n-j,	n-p,	g-o,
	i-e,	b-o,	a-l,	l-h,	g-p,	m-l,	e-h,	d-k,	m-c,	m-f,
	h-d,	a-g,	k-d,	m-a,	h-m,	c-m,	p-g,	a-h,	g-m,	d-l,
	n-g,	i-n,	f-p,	g-l,	i-h,	h-k,	p-b,	e-a,	e-l,	e-d,
	g-h,	d-g,	o-e,	o-m,	g-a,	b-c,	p-k,	b-n,	a-m,	d-m,
	b-i,	o-b,	g-k,	i-f,	f-e,	d-b,	i-j,	l-j,	b-m,	i-b,
	b-d,	m-d,	j-l,	l-i,	d-j,	j-n,	d-c,	p-h,	o-h,	c-p,
	p-l,	m-i,	j-d,	c-l,	m-p,	o-k,	f-k,	k-l,	n-k,	j-f,
	d-e,	d-n,	m-n,	c-a,	g-j,	k-p,	k-m,	b-a,	h-f,	e-c,
	j-a,	o-d,	k-b,	h-b,	a-j,	c-o,	d-f,	f-d,	e-o,	f-i,
	o-a,	i-p,	d-o,	m-g,	d-i,	e-j,	e-k,	o-f,	k-j,	h-i,
	h-n,	l-n,	f-l,	c-n,	i-o,	p-m,	d-h,	p-e,	o-j,	m-j,
	i-l,	n-l,	l-e,	a-c,	n-b,	h-a,	f-o,	b-e,	o-g,	i-g,
	l-b,	l-d,	l-o,	e-g,	i-m,	n-i,	a-o,	l-p,	f-j,	n-o,
	a-f,	k-c,	g-d,	k-h,	n-f,	b-h,	g-b,	o-c,	n-e,	j-b,
	j-m,	k-g,	e-i,	h-o,	l-f,	c-j,	c-d,	j-o,	k-n,	n-c,
	h-p,	c-g,	j-p,	c-i,	p-o,	g-n,	i-d,	e-f,	g-c,	k-i,
	l-a,	i-a,	i-k,	j-e,	m-b,	c-k,	j-k,	f-b,	p-d,	m-k,
	l-g,	g-f,	f-h,	b-f,	i-c,	p-i,	b-l,	e-p,	f-n,	f-a,
	a-d,	e-n,	a-p,	j-c,	l-c,	a-b,	k-o,	o-i,	e-b,	k-a,
	d-p,	d-a,	p-n,	b-g,	b-k,	o-p,	g-e,	o-n,	l-k,	j-i,
	k-e,	h-g,	l-m,	p-c,	m-h,	p-j,	b-j,	h-l,	h-c,	n-h,
	f-c,	f-m,	j-g,	g-i,	e-m,	c-e,	n-a,	f-g,	c-h,	c-b,
	a-n,	k-f,	c-f,	h-j,	h-e,	n-m,	p-f,	o-l,	b-p];
	return DV