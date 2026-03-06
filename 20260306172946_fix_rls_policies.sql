import React, { useState, useEffect, useRef } from 'react';
import { Menu, X, Phone, Mail, MapPin, Heart, Star, ChevronRight, ChevronLeft, MessageCircle, ArrowUp, Instagram, Facebook, Search } from 'lucide-react';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

function App() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [scrollPosition, setScrollPosition] = useState(0);
  const [showBackToTop, setShowBackToTop] = useState(false);
  const [bookingForm, setBookingForm] = useState({
    name: '',
    phone: '',
    service: 'custom',
    pickupDate: '',
    deliveryDate: '',
    instructions: '',
  });
  const [bookingErrors, setBookingErrors] = useState<Record<string, string>>({});
  const [bookingConfirmed, setBookingConfirmed] = useState(false);
  const [isSubmittingBooking, setIsSubmittingBooking] = useState(false);
  const [contactForm, setContactForm] = useState({ name: '', email: '', message: '' });
  const [contactErrors, setContactErrors] = useState<Record<string, string>>({});
  const [contactSubmitted, setContactSubmitted] = useState(false);
  const [isSubmittingContact, setIsSubmittingContact] = useState(false);
  const [user, setUser] = useState<any>(null);
  const [userBookings, setUserBookings] = useState<any[]>([]);
  const [testimonialIndex, setTestimonialIndex] = useState(0);
  const [visibleSections, setVisibleSections] = useState<Record<string, boolean>>({});

  const refs = {
    hero: useRef<HTMLDivElement>(null),
    services: useRef<HTMLDivElement>(null),
    process: useRef<HTMLDivElement>(null),
    booking: useRef<HTMLDivElement>(null),
    testimonials: useRef<HTMLDivElement>(null),
    gallery: useRef<HTMLDivElement>(null),
    signin: useRef<HTMLDivElement>(null),
    contact: useRef<HTMLDivElement>(null),
    footer: useRef<HTMLDivElement>(null),
  };

  useEffect(() => {
    const handleScroll = () => {
      const position = window.scrollY;
      setScrollPosition(position);
      setShowBackToTop(position > 300);

      Object.entries(refs).forEach(([key, ref]) => {
        if (ref.current) {
          const rect = ref.current.getBoundingClientRect();
          setVisibleSections(prev => ({
            ...prev,
            [key]: rect.top < window.innerHeight * 0.75
          }));
        }
      });
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const scrollToSection = (id: string) => {
    const element = refs[id as keyof typeof refs]?.current;
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
      setMobileMenuOpen(false);
    }
  };

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const validateBookingForm = () => {
    const errors: Record<string, string> = {};
    if (!bookingForm.name.trim()) errors.name = 'Name is required';
    if (!bookingForm.phone.trim()) errors.phone = 'Phone is required';
    if (!bookingForm.pickupDate) errors.pickupDate = 'Pickup date is required';
    if (!bookingForm.deliveryDate) errors.deliveryDate = 'Delivery date is required';

    if (bookingForm.pickupDate && bookingForm.deliveryDate) {
      const pickup = new Date(bookingForm.pickupDate);
      const delivery = new Date(bookingForm.deliveryDate);
      const minDelivery = new Date(pickup);
      minDelivery.setDate(minDelivery.getDate() + 3);

      if (delivery < minDelivery) {
        errors.deliveryDate = 'Delivery must be at least 3 days after pickup';
      }
    }

    setBookingErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleBookingSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateBookingForm()) return;

    setIsSubmittingBooking(true);
    try {
      const { error } = await supabase.from('bookings').insert([
        {
          name: bookingForm.name,
          phone: bookingForm.phone,
          service_type: bookingForm.service,
          pickup_date: bookingForm.pickupDate,
          delivery_date: bookingForm.deliveryDate,
          special_instructions: bookingForm.instructions,
          user_email: user?.email || null,
          status: 'pending',
        },
      ]);

      if (error) throw error;
      setBookingConfirmed(true);
      setBookingForm({ name: '', phone: '', service: 'custom', pickupDate: '', deliveryDate: '', instructions: '' });
      setTimeout(() => setBookingConfirmed(false), 5000);
    } catch (error) {
      console.error('Booking error:', error);
    } finally {
      setIsSubmittingBooking(false);
    }
  };

  const validateContactForm = () => {
    const errors: Record<string, string> = {};
    if (!contactForm.name.trim()) errors.name = 'Name is required';
    if (!contactForm.email.trim()) errors.email = 'Email is required';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(contactForm.email)) errors.email = 'Invalid email';
    if (!contactForm.message.trim()) errors.message = 'Message is required';

    setContactErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleContactSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateContactForm()) return;

    setIsSubmittingContact(true);
    try {
      const { error } = await supabase.from('contact_messages').insert([
        {
          name: contactForm.name,
          email: contactForm.email,
          message: contactForm.message,
          status: 'unread',
        },
      ]);

      if (error) throw error;
      setContactSubmitted(true);
      setContactForm({ name: '', email: '', message: '' });
      setTimeout(() => setContactSubmitted(false), 5000);
    } catch (error) {
      console.error('Contact error:', error);
    } finally {
      setIsSubmittingContact(false);
    }
  };

  const handleGoogleSignIn = async () => {
    const minDate = new Date();
    minDate.setDate(minDate.getDate());
    setBookingForm(prev => ({ ...prev, pickupDate: minDate.toISOString().split('T')[0] }));
  };

  const mockUser = {
    email: 'john@example.com',
    name: 'John Smith',
    picture: 'https://api.example.com/avatar.jpg',
  };

  const testimonials = [
    {
      name: 'Sarah Johnson',
      quote: 'Absolutely flawless work! My wedding dress was transformed perfectly. Highly recommended!',
      rating: 5,
    },
    {
      name: 'Michael Chen',
      quote: 'The attention to detail is incredible. My suits fit like they were made for me.',
      rating: 5,
    },
    {
      name: 'Emma Davis',
      quote: 'Fast service, reasonable prices, and exceptional quality. This is my go-to tailor!',
      rating: 5,
    },
  ];

  const services = [
    { title: 'Custom Stitching', icon: '✨', desc: 'Bespoke tailoring crafted to your exact specifications' },
    { title: 'Alterations & Repairs', icon: '🔧', desc: 'Expert adjustments to make any garment fit perfectly' },
    { title: 'Bridal Wear', icon: '💍', desc: 'Exquisite bridal gowns and ceremonial attire' },
    { title: 'Uniform Tailoring', icon: '👔', desc: 'Professional uniforms with precision tailoring' },
    { title: 'Kids Clothing', icon: '👶', desc: 'Comfortable and stylish garments for children' },
  ];

  const galleryImages = [
    { title: 'Bridal Suit', color: 'bg-red-200' },
    { title: 'School Uniform', color: 'bg-blue-200' },
    { title: 'Custom Blazer', color: 'bg-amber-200' },
    { title: 'Wedding Dress', color: 'bg-pink-200' },
    { title: 'Kids Party Wear', color: 'bg-purple-200' },
    { title: 'Corporate Uniform', color: 'bg-slate-200' },
  ];

  return (
    <div className="bg-[#FDF6EC] text-gray-800 font-lato">
      <style>{`
        * {
          font-family: 'Lato', sans-serif;
        }

        h1, h2, h3, h4, h5, h6 {
          font-family: 'Playfair Display', serif;
        }

        @keyframes fadeInUp {
          from {
            opacity: 0;
            transform: translateY(30px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }

        @keyframes slideInDown {
          from {
            opacity: 0;
            transform: translateY(-20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.7; }
        }

        .animate-fadeInUp {
          animation: fadeInUp 0.8s ease-out forwards;
        }

        .animate-fadeIn {
          animation: fadeIn 0.8s ease-out forwards;
        }

        .animate-slideInDown {
          animation: slideInDown 0.6s ease-out forwards;
        }

        .stagger-1 { animation-delay: 0.1s; opacity: 0; }
        .stagger-2 { animation-delay: 0.2s; opacity: 0; }
        .stagger-3 { animation-delay: 0.3s; opacity: 0; }
        .stagger-4 { animation-delay: 0.4s; opacity: 0; }
        .stagger-5 { animation-delay: 0.5s; opacity: 0; }

        .visible .stagger-1, .visible .stagger-2, .visible .stagger-3,
        .visible .stagger-4, .visible .stagger-5 {
          animation: fadeInUp 0.8s ease-out forwards;
        }

        .ornamental-divider {
          height: 3px;
          background: linear-gradient(to right, transparent, #F5A623, #D72638, #F5A623, transparent);
          margin: 2rem 0;
          position: relative;
        }

        .ornamental-divider::before {
          content: '';
          position: absolute;
          width: 8px;
          height: 8px;
          background: #D72638;
          border-radius: 50%;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
        }

        .card-hover {
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .card-hover:hover {
          transform: translateY(-8px);
          box-shadow: 0 20px 40px rgba(215, 38, 56, 0.15);
        }

        .button-gold {
          background: #F5A623;
          color: white;
          transition: all 0.3s ease;
        }

        .button-gold:hover {
          background: #E39820;
          box-shadow: 0 8px 16px rgba(245, 166, 35, 0.3);
          transform: translateY(-2px);
        }

        .button-outlined {
          border: 2px solid white;
          color: white;
          transition: all 0.3s ease;
        }

        .button-outlined:hover {
          background: white;
          color: #D72638;
        }

        .scrollbar-gold::-webkit-scrollbar {
          width: 8px;
        }

        .scrollbar-gold::-webkit-scrollbar-track {
          background: #FDF6EC;
        }

        .scrollbar-gold::-webkit-scrollbar-thumb {
          background: #F5A623;
          border-radius: 4px;
        }

        .scrollbar-gold::-webkit-scrollbar-thumb:hover {
          background: #D72638;
        }

        @media (prefers-reduced-motion: reduce) {
          * {
            animation-duration: 0.01ms !important;
            animation-iteration-count: 1 !important;
            transition-duration: 0.01ms !important;
          }
        }
      `}</style>

      {/* Navigation */}
      <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${scrollPosition > 50 ? 'bg-white shadow-lg' : 'bg-transparent'}`}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-[#D72638] flex items-center justify-center">
              <span className="text-[#F5A623] font-bold text-lg">S&S</span>
            </div>
            <span className={`text-lg font-bold hidden sm:block ${scrollPosition > 50 ? 'text-[#D72638]' : 'text-white'}`}>
              Stitch & Style
            </span>
          </div>

          <div className="hidden md:flex gap-8 items-center">
            {['Services', 'Booking', 'Contact'].map((item) => (
              <button
                key={item}
                onClick={() => scrollToSection(item.toLowerCase())}
                className={`text-sm font-medium transition ${scrollPosition > 50 ? 'text-gray-700 hover:text-[#D72638]' : 'text-white hover:text-[#F5A623]'}`}
              >
                {item}
              </button>
            ))}
            {user && (
              <button className="text-xs font-medium text-white bg-[#D72638] px-4 py-2 rounded hover:bg-[#C41F2E] transition">
                My Orders
              </button>
            )}
          </div>

          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden text-white p-2"
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {mobileMenuOpen && (
          <div className="md:hidden bg-[#D72638] text-white animate-slideInDown">
            <div className="px-4 py-4 space-y-3">
              {['Services', 'Booking', 'Contact'].map((item) => (
                <button
                  key={item}
                  onClick={() => scrollToSection(item.toLowerCase())}
                  className="block w-full text-left py-2 hover:text-[#F5A623]"
                >
                  {item}
                </button>
              ))}
            </div>
          </div>
        )}
      </nav>

      {/* Hero Section */}
      <section ref={refs.hero} className="relative min-h-screen flex items-center justify-center pt-20 overflow-hidden" style={{
        background: 'linear-gradient(135deg, #D72638 0%, #A01A2A 50%, #6B1120 100%)',
      }}>
        <div className="absolute inset-0 opacity-10" style={{
          backgroundImage: 'repeating-linear-gradient(45deg, transparent, transparent 35px, rgba(255,255,255,.1) 35px, rgba(255,255,255,.1) 70px)',
        }}></div>

        <div className="relative z-10 text-center px-4 max-w-3xl mx-auto">
          <h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold text-white mb-6 animate-fadeInUp">
            Crafted to Fit.<br />Made for You.
          </h1>
          <p className="text-lg sm:text-xl text-[#F5A623] mb-8 animate-fadeInUp stagger-1">
            Premium tailoring for every occasion
          </p>

          <svg className="w-24 h-24 mx-auto mb-8 animate-fadeInUp stagger-2" viewBox="0 0 100 100" fill="none">
            <path d="M20 50 Q40 40 60 50 T100 50" stroke="#F5A623" strokeWidth="2" strokeLinecap="round" />
            <circle cx="50" cy="50" r="3" fill="#F5A623" />
            <path d="M50 30 L50 20 M50 70 L50 80" stroke="#F5A623" strokeWidth="1.5" />
          </svg>

          <div className="flex flex-col sm:flex-row gap-4 justify-center animate-fadeInUp stagger-3">
            <button onClick={() => scrollToSection('booking')} className="button-gold px-8 py-4 text-lg font-semibold rounded-lg">
              Book Now
            </button>
            <button onClick={() => scrollToSection('services')} className="button-outlined px-8 py-4 text-lg font-semibold rounded-lg">
              View Services
            </button>
          </div>
        </div>

        <div className="absolute bottom-10 left-1/2 transform -translate-x-1/2 animate-bounce">
          <ChevronRight className="rotate-90 text-white opacity-70" size={32} />
        </div>
      </section>

      {/* Services Section */}
      <section ref={refs.services} className={`py-20 px-4 ${visibleSections.services ? 'visible' : ''}`}>
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl sm:text-5xl font-bold text-center mb-4 text-[#D72638]">Our Services</h2>
          <div className="ornamental-divider"></div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
            {services.map((service, i) => (
              <div
                key={i}
                className={`bg-white p-8 rounded-lg card-hover border-l-4 border-[#F5A623] stagger-${(i % 5) + 1}`}
              >
                <div className="text-5xl mb-4">{service.icon}</div>
                <h3 className="text-2xl font-bold text-[#D72638] mb-3">{service.title}</h3>
                <p className="text-gray-600 mb-6">{service.desc}</p>
                <button className="text-[#F5A623] font-semibold hover:text-[#D72638] transition inline-flex items-center gap-2">
                  Learn More <ChevronRight size={18} />
                </button>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section ref={refs.process} className={`py-20 px-4 bg-white ${visibleSections.process ? 'visible' : ''}`}>
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl sm:text-5xl font-bold text-center mb-4 text-[#D72638]">How It Works</h2>
          <div className="ornamental-divider"></div>

          <div className="grid md:grid-cols-3 gap-8 mt-12 relative">
            {['Choose Style', 'Schedule Pickup', 'Receive Delivery'].map((step, i) => (
              <div key={i} className="relative text-center">
                <div className="w-16 h-16 rounded-full bg-[#D72638] text-white flex items-center justify-center mx-auto mb-6 text-2xl font-bold">
                  {i + 1}
                </div>
                <h3 className="text-xl font-bold text-gray-800 mb-3">{step}</h3>
                <p className="text-gray-600 text-sm">
                  {i === 0 && 'Browse our services and select the perfect style for your needs'}
                  {i === 1 && 'Choose your preferred pickup and delivery dates'}
                  {i === 2 && 'Receive your beautifully tailored garments on time'}
                </p>
                {i < 2 && (
                  <div className="hidden md:block absolute top-8 -right-4 w-8 h-1 bg-[#F5A623]"></div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Booking Section */}
      <section ref={refs.booking} className={`py-20 px-4 ${visibleSections.booking ? 'visible' : ''}`} style={{
        background: 'linear-gradient(135deg, #FDF6EC 0%, #F9F1E2 100%)',
      }}>
        <div className="max-w-2xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-4 text-[#D72638]">Schedule Your Delivery</h2>
          <div className="ornamental-divider"></div>

          {bookingConfirmed ? (
            <div className="mt-12 bg-white p-8 rounded-lg text-center border-2 border-[#F5A623] animate-fadeInUp">
              <div className="w-20 h-20 rounded-full bg-green-500 text-white flex items-center justify-center mx-auto mb-6 text-4xl">
                ✓
              </div>
              <h3 className="text-2xl font-bold text-[#D72638] mb-2">Booking Confirmed!</h3>
              <p className="text-gray-600 mb-4">We'll contact you shortly at {bookingForm.phone} to confirm details.</p>
              <p className="text-sm text-gray-500">Pickup: {bookingForm.pickupDate} | Delivery: {bookingForm.deliveryDate}</p>
            </div>
          ) : (
            <form onSubmit={handleBookingSubmit} className="mt-12 bg-white p-8 rounded-lg shadow-lg space-y-6">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Name *</label>
                <input
                  type="text"
                  value={bookingForm.name}
                  onChange={(e) => setBookingForm({ ...bookingForm, name: e.target.value })}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                  placeholder="Your name"
                />
                {bookingErrors.name && <p className="text-red-500 text-sm mt-1">{bookingErrors.name}</p>}
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Phone *</label>
                <input
                  type="tel"
                  value={bookingForm.phone}
                  onChange={(e) => setBookingForm({ ...bookingForm, phone: e.target.value })}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                  placeholder="Your phone number"
                />
                {bookingErrors.phone && <p className="text-red-500 text-sm mt-1">{bookingErrors.phone}</p>}
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Service</label>
                <select
                  value={bookingForm.service}
                  onChange={(e) => setBookingForm({ ...bookingForm, service: e.target.value })}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                >
                  <option value="custom">Custom Stitching</option>
                  <option value="alteration">Alterations & Repairs</option>
                  <option value="bridal">Bridal Wear</option>
                  <option value="uniform">Uniform Tailoring</option>
                  <option value="kids">Kids Clothing</option>
                </select>
              </div>

              <div className="grid sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Pickup Date *</label>
                  <input
                    type="date"
                    value={bookingForm.pickupDate}
                    onChange={(e) => setBookingForm({ ...bookingForm, pickupDate: e.target.value })}
                    min={new Date().toISOString().split('T')[0]}
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                  />
                  {bookingErrors.pickupDate && <p className="text-red-500 text-sm mt-1">{bookingErrors.pickupDate}</p>}
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Delivery Date *</label>
                  <input
                    type="date"
                    value={bookingForm.deliveryDate}
                    onChange={(e) => setBookingForm({ ...bookingForm, deliveryDate: e.target.value })}
                    min={bookingForm.pickupDate ? new Date(new Date(bookingForm.pickupDate).getTime() + 3 * 24 * 60 * 60 * 1000).toISOString().split('T')[0] : undefined}
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                  />
                  {bookingErrors.deliveryDate && <p className="text-red-500 text-sm mt-1">{bookingErrors.deliveryDate}</p>}
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Special Instructions</label>
                <textarea
                  value={bookingForm.instructions}
                  onChange={(e) => setBookingForm({ ...bookingForm, instructions: e.target.value })}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                  placeholder="Any special requests or details..."
                  rows={4}
                ></textarea>
              </div>

              <button
                type="submit"
                disabled={isSubmittingBooking}
                className="w-full button-gold py-4 text-lg font-semibold rounded-lg transition disabled:opacity-50"
              >
                {isSubmittingBooking ? 'Confirming...' : 'Confirm Booking'}
              </button>
            </form>
          )}
        </div>
      </section>

      {/* Testimonials */}
      <section ref={refs.testimonials} className={`py-20 px-4 bg-white ${visibleSections.testimonials ? 'visible' : ''}`}>
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-4 text-[#D72638]">What Our Customers Say</h2>
          <div className="ornamental-divider"></div>

          <div className="mt-12 relative">
            <div className="grid md:grid-cols-3 gap-8 items-center">
              {testimonials.map((testimonial, i) => (
                <div
                  key={i}
                  className={`bg-[#FDF6EC] p-8 rounded-lg border-l-4 border-[#F5A623] transition-all duration-500 ${i === testimonialIndex ? 'scale-105 md:scale-100' : 'hidden md:block'}`}
                >
                  <div className="flex gap-1 mb-4">
                    {[...Array(testimonial.rating)].map((_, j) => (
                      <Star key={j} size={20} className="fill-[#F5A623] text-[#F5A623]" />
                    ))}
                  </div>
                  <p className="text-gray-700 mb-4 italic">"{testimonial.quote}"</p>
                  <p className="font-bold text-[#D72638]">{testimonial.name}</p>
                </div>
              ))}
            </div>

            <div className="flex justify-center gap-4 mt-8 md:hidden">
              <button
                onClick={() => setTestimonialIndex(testimonialIndex === 0 ? testimonials.length - 1 : testimonialIndex - 1)}
                className="p-2 rounded-full bg-[#D72638] text-white hover:bg-[#C41F2E] transition"
              >
                <ChevronLeft size={24} />
              </button>
              <button
                onClick={() => setTestimonialIndex((testimonialIndex + 1) % testimonials.length)}
                className="p-2 rounded-full bg-[#D72638] text-white hover:bg-[#C41F2E] transition"
              >
                <ChevronRight size={24} />
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Gallery */}
      <section ref={refs.gallery} className={`py-20 px-4 ${visibleSections.gallery ? 'visible' : ''}`} style={{
        background: 'linear-gradient(135deg, #FDF6EC 0%, #F9F1E2 100%)',
      }}>
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-4 text-[#D72638]">Our Portfolio</h2>
          <div className="ornamental-divider"></div>

          <div className="mt-12 grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {galleryImages.map((item, i) => (
              <div
                key={i}
                className={`relative h-64 ${item.color} rounded-lg overflow-hidden group cursor-pointer card-hover stagger-${(i % 5) + 1}`}
              >
                <div className="absolute inset-0 flex items-center justify-center text-white text-center">
                  <div>
                    <div className="text-5xl mb-3">📷</div>
                    <p className="font-bold text-lg">{item.title}</p>
                  </div>
                </div>
                <div className="absolute inset-0 bg-[#D72638] opacity-0 group-hover:opacity-75 transition-opacity duration-300 flex items-center justify-center">
                  <span className="text-white font-bold text-center px-4">{item.title}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Sign In Section */}
      <section ref={refs.signin} className={`py-20 px-4 bg-white ${visibleSections.signin ? 'visible' : ''}`}>
        <div className="max-w-2xl mx-auto text-center">
          <h2 className="text-4xl font-bold mb-4 text-[#D72638]">Sign In to Track Your Orders</h2>
          <div className="ornamental-divider"></div>

          <div className="mt-12 bg-[#FDF6EC] p-8 rounded-lg">
            {!user ? (
              <div>
                <p className="text-gray-600 mb-8">Sign in to view your order history and delivery status</p>
                <button onClick={handleGoogleSignIn} className="w-full button-gold px-6 py-4 rounded-lg font-semibold text-lg">
                  Sign in with Google
                </button>
                <p className="text-xs text-gray-500 mt-4">This is a demo. Use your Google account to test.</p>
              </div>
            ) : (
              <div>
                <div className="inline-block w-20 h-20 rounded-full bg-gradient-to-br from-[#D72638] to-[#F5A623] mb-4 flex items-center justify-center text-white text-2xl">
                  {mockUser.name.charAt(0)}
                </div>
                <p className="text-xl font-bold text-[#D72638] mb-2">{mockUser.name}</p>
                <p className="text-gray-600 mb-6">{mockUser.email}</p>

                <div className="bg-white p-6 rounded-lg mb-6 text-left">
                  <h3 className="font-bold text-[#D72638] mb-4">My Orders</h3>
                  {userBookings.length > 0 ? (
                    <div className="space-y-3">
                      {userBookings.map((booking, i) => (
                        <div key={i} className="p-3 bg-gray-50 rounded border-l-4 border-[#F5A623]">
                          <p className="font-semibold text-gray-800">{booking.service_type}</p>
                          <p className="text-sm text-gray-600">Delivery: {booking.delivery_date}</p>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-gray-600 text-sm">No orders yet. Book your tailoring session now!</p>
                  )}
                </div>

                <button className="w-full button-outlined px-6 py-3 rounded-lg font-semibold">
                  Sign Out
                </button>
              </div>
            )}
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section ref={refs.contact} className={`py-20 px-4 ${visibleSections.contact ? 'visible' : ''}`} style={{
        background: 'linear-gradient(135deg, #FDF6EC 0%, #F9F1E2 100%)',
      }}>
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-4 text-[#D72638]">Get in Touch</h2>
          <div className="ornamental-divider"></div>

          <div className="mt-12 grid md:grid-cols-2 gap-12">
            <div>
              <h3 className="text-2xl font-bold text-[#D72638] mb-8">Contact Information</h3>

              <div className="space-y-6">
                <div className="flex gap-4">
                  <MapPin className="text-[#F5A623] flex-shrink-0" size={24} />
                  <div>
                    <p className="font-semibold text-gray-800">Address</p>
                    <p className="text-gray-600">123 Fashion Lane, Style City, SC 12345</p>
                  </div>
                </div>

                <div className="flex gap-4">
                  <Phone className="text-[#F5A623] flex-shrink-0" size={24} />
                  <div>
                    <p className="font-semibold text-gray-800">Phone</p>
                    <p className="text-gray-600">(555) 123-4567</p>
                  </div>
                </div>

                <div className="flex gap-4">
                  <Mail className="text-[#F5A623] flex-shrink-0" size={24} />
                  <div>
                    <p className="font-semibold text-gray-800">Email</p>
                    <p className="text-gray-600">hello@stitchstyle.com</p>
                  </div>
                </div>

                <div>
                  <p className="font-semibold text-gray-800 mb-3">Hours</p>
                  <p className="text-gray-600">Monday - Saturday: 9:00 AM - 8:00 PM</p>
                  <p className="text-gray-600">Sunday: Closed</p>
                </div>
              </div>

              <div className="mt-8 w-full h-64 rounded-lg overflow-hidden border-2 border-[#D72638]">
                <iframe
                  src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3022.9663095347603!2d-74.00601612346047!3d40.71284097138067!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89c25a23e0eeeeefd%3A0x15e13efb2fdf0c69!2sFlatiron%20Building!5e0!3m2!1sen!2sus!4v1234567890"
                  width="100%"
                  height="100%"
                  style={{ border: 0 }}
                  allowFullScreen
                  loading="lazy"
                ></iframe>
              </div>
            </div>

            <div>
              {contactSubmitted ? (
                <div className="bg-white p-8 rounded-lg text-center border-2 border-[#F5A623] h-full flex flex-col items-center justify-center animate-fadeInUp">
                  <div className="w-16 h-16 rounded-full bg-green-500 text-white flex items-center justify-center mx-auto mb-4 text-3xl">
                    ✓
                  </div>
                  <h3 className="text-2xl font-bold text-[#D72638] mb-2">Message Sent!</h3>
                  <p className="text-gray-600">Thanks for reaching out. We'll get back to you soon!</p>
                </div>
              ) : (
                <form onSubmit={handleContactSubmit} className="bg-white p-8 rounded-lg shadow-lg space-y-6">
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Name</label>
                    <input
                      type="text"
                      value={contactForm.name}
                      onChange={(e) => setContactForm({ ...contactForm, name: e.target.value })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                      placeholder="Your name"
                    />
                    {contactErrors.name && <p className="text-red-500 text-sm mt-1">{contactErrors.name}</p>}
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Email</label>
                    <input
                      type="email"
                      value={contactForm.email}
                      onChange={(e) => setContactForm({ ...contactForm, email: e.target.value })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                      placeholder="Your email"
                    />
                    {contactErrors.email && <p className="text-red-500 text-sm mt-1">{contactErrors.email}</p>}
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Message</label>
                    <textarea
                      value={contactForm.message}
                      onChange={(e) => setContactForm({ ...contactForm, message: e.target.value })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-[#D72638] transition"
                      placeholder="Your message"
                      rows={5}
                    ></textarea>
                    {contactErrors.message && <p className="text-red-500 text-sm mt-1">{contactErrors.message}</p>}
                  </div>

                  <button
                    type="submit"
                    disabled={isSubmittingContact}
                    className="w-full button-gold py-3 font-semibold rounded-lg transition disabled:opacity-50"
                  >
                    {isSubmittingContact ? 'Sending...' : 'Send Message'}
                  </button>
                </form>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer ref={refs.footer} className="bg-[#1a1a1a] text-white">
        <div className="border-t-2 border-[#F5A623]"></div>

        <div className="max-w-6xl mx-auto px-4 py-16">
          <div className="grid md:grid-cols-4 gap-8 mb-12">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <div className="w-10 h-10 rounded-full bg-[#D72638] flex items-center justify-center">
                  <span className="text-[#F5A623] font-bold">S&S</span>
                </div>
                <span className="font-bold">Stitch & Style</span>
              </div>
              <p className="text-gray-400 text-sm">Where Every Thread Tells a Story</p>
            </div>

            <div>
              <h4 className="font-bold mb-4">Quick Links</h4>
              <ul className="space-y-2 text-sm text-gray-400">
                <li><button onClick={() => scrollToSection('services')} className="hover:text-[#F5A623]">Services</button></li>
                <li><button onClick={() => scrollToSection('booking')} className="hover:text-[#F5A623]">Booking</button></li>
                <li><button onClick={() => scrollToSection('contact')} className="hover:text-[#F5A623]">Contact</button></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold mb-4">Hours</h4>
              <ul className="space-y-2 text-sm text-gray-400">
                <li>Mon - Sat: 9AM - 8PM</li>
                <li>Sunday: Closed</li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold mb-4">Follow Us</h4>
              <div className="flex gap-4">
                <button className="text-gray-400 hover:text-[#F5A623] transition">
                  <Instagram size={20} />
                </button>
                <button className="text-gray-400 hover:text-[#F5A623] transition">
                  <Facebook size={20} />
                </button>
                <button className="text-gray-400 hover:text-[#F5A623] transition">
                  <MessageCircle size={20} />
                </button>
              </div>
            </div>
          </div>

          <div className="border-t border-gray-800 pt-8 text-center text-sm text-gray-400">
            <p>&copy; {new Date().getFullYear()} Stitch & Style Tailors. All rights reserved.</p>
          </div>
        </div>
      </footer>

      {/* Floating Buttons */}
      <a
        href="https://wa.me/5551234567"
        target="_blank"
        rel="noopener noreferrer"
        className="fixed bottom-6 right-6 bg-green-500 text-white p-4 rounded-full shadow-lg hover:bg-green-600 transition z-40 hover:scale-110"
        title="Chat on WhatsApp"
      >
        <MessageCircle size={24} />
      </a>

      {showBackToTop && (
        <button
          onClick={scrollToTop}
          className="fixed bottom-24 right-6 bg-[#D72638] text-white p-3 rounded-full shadow-lg hover:bg-[#C41F2E] transition z-40 animate-fadeInUp"
          title="Back to top"
        >
          <ArrowUp size={24} />
        </button>
      )}
    </div>
  );
}

export default App;
