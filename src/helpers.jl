# g + g^2 + ... + g^(T-1)
pvfactor(g, T) = (g ^ T - 1.0) / (g - 1.0);

# Present value. First entry not discounted.
present_value(xV, R) = sum(xV ./ (R .^ (0 : (length(xV)-1))));

# -----------